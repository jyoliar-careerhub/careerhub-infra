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

data "aws_iam_policy_document" "codebuild_policy_doc" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]

    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateNetworkInterfacePermission"]
    resources = ["arn:aws:ec2:*:*:network-interface/*"]

    condition {
      test     = "ArnEquals"
      variable = "ec2:Subnet"

      values = var.subnet_arns
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.codebuild_bucket.arn,
      "${aws_s3_bucket.codebuild_bucket.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "codebuild_assume_role_policy_doc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = local.codebuild_name
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role_policy_doc.json
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
  role   = aws_iam_role.codebuild_role.name
  policy = data.aws_iam_policy_document.codebuild_policy_doc.json
}

resource "aws_s3_bucket" "codebuild_bucket" {
  bucket        = "${local.codebuild_name}-${random_string.bucket_suffix.result}"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "codebuild_bucket" {
  bucket = aws_s3_bucket.codebuild_bucket.id

  rule {
    id     = "expiration"
    status = "Enabled"

    expiration {
      days = 3
    }
  }
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
  service_role  = aws_iam_role.codebuild_role.arn

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
      location = "${aws_s3_bucket.codebuild_bucket.id}/build-log"
    }
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.codebuild_bucket.bucket
  }

  source {
    type = "CODEPIPELINE"
    buildspec = templatefile("${path.module}/buildspec_template.yml", {
      region          = data.aws_region.current.name
      ecr_domain      = aws_ecr_repository.ecr_repo.repository_url
      image_repo_name = aws_ecr_repository.ecr_repo.name
    })
  }

  vpc_config {
    vpc_id = var.vpc_id

    subnets = local.subnet_ids

    security_group_ids = [
      aws_security_group.codebuild_sg.id,
    ]
  }
}

data "aws_region" "current" {}

resource "aws_security_group" "codebuild_sg" {
  name        = local.codebuild_name
  description = "Security group for codebuild"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.codebuild_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
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

data "aws_iam_policy_document" "codepipeline_assume_role_doc" {


  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = local.codepipeline_name
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role_doc.json
}

data "aws_iam_policy_document" "codepipeline_policy_doc" {
  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [var.connection_arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.codebuild_bucket.arn,
      "${aws_s3_bucket.codebuild_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = local.codepipeline_name
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy_doc.json
}


resource "aws_codepipeline" "codepipeline" {
  name     = local.codepipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codebuild_bucket.bucket
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
