locals {
  subnet_ids = [for arn in var.subnet_arns : regex("^arn:aws:ec2:[^:]+:\\d+:subnet/(.+)$", arn)[0]]
}

### start define ecr
resource "aws_ecr_repository" "ecr_repo" {
  name = "${var.name}-ecr"

  image_tag_mutability = "MUTABLE"
  force_delete         = true
}
### end define ecr

### start define codebuild config
locals {
  codebuild_name = "${var.name}-cb"
}



locals {
  codebuild_enviroment = {
    arm64 = {
      type         = "ARM_CONTAINER"
      compute_type = "BUILD_GENERAL1_SMALL"
      image        = "aws/codebuild/amazonlinux2-aarch64-standard:3.0"
    }
    x86_64 = {
      type         = "LINUX_CONTAINER"
      compute_type = "BUILD_GENERAL1_SMALL"
      image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    }
  }
}

resource "aws_codebuild_project" "codebuild_project" {
  name          = local.codebuild_name
  description   = "CodeBuild for ${var.name}"
  build_timeout = 30
  service_role  = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    image_pull_credentials_type = "CODEBUILD"
    type                        = local.codebuild_enviroment[var.build_arch].type
    compute_type                = local.codebuild_enviroment[var.build_arch].compute_type
    image                       = local.codebuild_enviroment[var.build_arch].image
    privileged_mode             = true
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "${var.name}-lg"
      stream_name = "${var.name}-ls"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${var.codebuild_bucket_id}/build-log/${local.codebuild_name}"
    }
  }

  cache {
    type     = "S3"
    location = var.codebuild_bucket
  }

  source {
    type = "CODEPIPELINE"
    buildspec = templatefile("${path.module}/buildspec_template.yml", {
      region          = var.region
      ecr_domain      = split("/", aws_ecr_repository.ecr_repo.repository_url)[0]
      image_repo_name = aws_ecr_repository.ecr_repo.name
    })
  }

  vpc_config {
    vpc_id = var.vpc_id

    subnets = local.subnet_ids

    security_group_ids = [
      var.codebuild_sg_id
    ]
  }
}

### end define codebuild


### start define codepipeline
locals {
  codepipeline_name = "${var.name}-cp"
}

resource "random_string" "bucket_suffix" {
  length  = 6
  upper   = false
  lower   = true
  special = false
}


resource "aws_codepipeline" "codepipeline" {
  name     = local.codepipeline_name
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.codebuild_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.connection_arn
        FullRepositoryId = var.repository_path
        BranchName       = var.branch_name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_project.name
      }
    }
  }
}
