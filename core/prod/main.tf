locals {
  code_pipelines = {
    posting-service = {
      repository_path = "jyoliar-careerhub/careerhub-posting-service"
      mongodb = {
        collection_name = "posting"
      }
    }
    review-service = {
      repository_path = "jyoliar-careerhub/careerhub-review-service"
      mongodb = {
        collection_name = "review"
      }
    }
    userinfo-service = {
      repository_path = "jyoliar-careerhub/careerhub-userinfo-service"
      mongodb = {
        collection_name = "userinfo"
      }
    }
    posting-provider = {
      repository_path = "jyoliar-careerhub/careerhub-posting-provider"
    }
    posting-skillscanner = {
      repository_path = "jyoliar-careerhub/careerhub-posting-skillscanner"
    }
    review-crawler = {
      repository_path = "jyoliar-careerhub/careerhub-review-crawler"
    }
    api-composer = {
      repository_path = "jyoliar-careerhub/careerhub-api-composer"
    }
    auth-service = {
      repository_path = "jyoliar-careerhub/auth-service"
    }
  }
}

resource "aws_codestarconnections_connection" "this" {
  name          = "${var.env}-careerhub"
  provider_type = "GitHub"
}

data "aws_subnet" "private_subnet_ids" {
  count = length(local.careerhub_subnets_outputs.private_subnet_ids)

  id = local.careerhub_subnets_outputs.private_subnet_ids[count.index]
}

module "code_pipeline" {
  source = "../_modules/code_pipeline"

  for_each = local.code_pipelines

  name            = "${var.env}-${each.key}"
  build_arch      = "arm64"
  repository_path = each.value.repository_path
  branch_name     = "prod"

  vpc_id         = local.careerhub_subnets_outputs.vpc_id
  subnet_arns    = [for subnet in data.aws_subnet.private_subnet_ids : subnet.arn]
  connection_arn = aws_codestarconnections_connection.this.arn
}

module "pod_identity" {
  for_each = {
    for k, v in local.code_pipelines : k => v
    if contains(keys(v), "mongodb")
  }
  source = "../_modules/pod_identity"


  name                 = "${var.env}-${each.key}"
  namespace            = "${var.env}-careerhub"
  service_account_name = each.key
  cluster_arn          = local.eks_outputs.eks_cluster_arn
}


resource "mongodbatlas_database_user" "this" {
  for_each = {
    for k, v in local.code_pipelines : k => v
    if contains(keys(v), "mongodb")
  }

  project_id = local.mongodb_outputs.project_id
  username   = module.pod_identity[each.key].role_arn

  auth_database_name = "$external"
  aws_iam_type       = "ROLE"

  roles {
    role_name       = "readWrite"
    database_name   = local.mongodb_outputs.mongodb_database_name
    collection_name = each.value.mongodb.collection_name
  }
}

# mongodb privatelink가 생성된 이후 private endpoint가 생성되기 때문에
# 현재 워크스페이스에서 data로 가져와야 함
data "mongodbatlas_advanced_cluster" "this" {
  project_id = local.mongodb_outputs.project_id
  name       = local.mongodb_outputs.mongodb_database_name
}

resource "aws_ssm_parameter" "mongodb_secret" {
  for_each = {
    for k, v in local.code_pipelines : k => v
    if contains(keys(v), "mongodb")
  }

  name = "/${local.eks_outputs.eks_cluster_name}/careerhub/${var.env}/${each.key}/mongodb"
  type = "String"
  value = jsonencode({
    endpoint   = data.mongodbatlas_advanced_cluster.this.connection_strings[0].private_endpoint[0].srv_connection_string
    collection = each.value.mongodb.collection_name
  })
  description = "MongoDB Atlas secret for ${each.key} service"
}


data "aws_caller_identity" "current" {}
resource "aws_iam_policy" "careerhub-secrets-reader" {
  name = "${var.env}-careerhub-secrets-reader"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSpecificSecret"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter*"
        ]

        Resource = [
          "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${local.eks_outputs.eks_cluster_name}/careerhub/*"
        ]
      }
    ]
  })
}

module "role_for_sa" {
  source = "../_modules/role_for_sa"

  name                  = "${var.env}-careerhub-secrets-reader"
  eks_oidc_provider_arn = local.eks_outputs.eks_oidc_provider_arn
  namespace             = "${var.env}-careerhub"
  service_account_name  = "careerhub-secrets-reader"

  policy_arn = aws_iam_policy.careerhub-secrets-reader.arn
}
