locals {
  code_pipelines = {
    posting-provider = {
      source = "./backend_cicd_infra"

      cicd_name  = "posting-provider"
      build_arch = "arm64"

      repository_path = "jyoliar-careerhub/careerhub-posting-provider"
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

  name            = "${var.env}-${each.value.cicd_name}"
  build_arch      = each.value.build_arch
  repository_path = each.value.repository_path
  branch_name     = "prod"

  vpc_id         = local.careerhub_subnets_outputs.vpc_id
  subnet_arns    = [for subnet in data.aws_subnet.private_subnet_ids : subnet.arn]
  connection_arn = aws_codestarconnections_connection.this.arn
}
