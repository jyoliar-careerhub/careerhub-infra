locals {
  code_pipelines = {
    posting-provider = {
      cicd_name       = "posting-provider"
      repository_path = "jyoliar-careerhub/careerhub-posting-provider"
    }
    # posting-service = {
    #   cicd_name       = "posting-service"
    #   repository_path = "jyoliar-careerhub/careerhub-posting-service"
    # }

    # posting-skillscanner = {
    #   cicd_name       = "posting-skillscanner"
    #   repository_path = "jyoliar-careerhub/careerhub-posting-skillscanner"
    # }
    # review-crawler = {
    #   cicd_name       = "review-crawler"
    #   repository_path = "jyoliar-careerhub/careerhub-review-crawler"
    # }
    # review-service = {
    #   cicd_name       = "review-service"
    #   repository_path = "jyoliar-careerhub/careerhub-review-service"
    # }
    # userinfo-service = {
    #   cicd_name       = "userinfo-service"
    #   repository_path = "jyoliar-careerhub/careerhub-userinfo-service"
    # }
    # api-composer = {
    #   cicd_name       = "api-composer"
    #   repository_path = "jyoliar-careerhub/careerhub-api-composer"
    # }
    # auth-service = {
    #   cicd_name       = "auth-service"
    #   repository_path = "jyoliar-careerhub/auth-service"
    # }
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

  name            = "${var.env}-${each.value.cicd_name}"
  build_arch      = "arm64"
  repository_path = each.value.repository_path
  branch_name     = "prod"

  vpc_id         = local.careerhub_subnets_outputs.vpc_id
  subnet_arns    = [for subnet in data.aws_subnet.private_subnet_ids : subnet.arn]
  connection_arn = aws_codestarconnections_connection.this.arn
}
