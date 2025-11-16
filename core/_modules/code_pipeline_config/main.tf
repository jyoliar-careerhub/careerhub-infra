locals {
  codebuild_name    = "${var.env}-codebuild"
  codepipeline_name = "${var.env}-codepipeline"
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
resource "random_string" "bucket_suffix" {
  length  = 6
  upper   = false
  lower   = true
  special = false
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
resource "aws_codestarconnections_connection" "this" {
  name          = "${var.env}-careerhub"
  provider_type = "GitHub"
}

data "aws_iam_policy_document" "codepipeline_policy_doc" {
  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [aws_codestarconnections_connection.this.arn]
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
