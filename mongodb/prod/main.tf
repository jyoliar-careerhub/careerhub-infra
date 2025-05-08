data "mongodbatlas_roles_org_id" "current" {
}

module "mongodb_atlas_project" {
  source = "../_modules/mongodb_atlas_project"

  name = "${var.env}-careerhub"

  organization_id = data.mongodbatlas_roles_org_id.current.id
}

module "mongodb_privatelink" {
  source = "../_modules/mongodb_privatelink"

  name       = "${var.env}-mongodb-privatelink"
  vpc_id     = local.careerhub_subnets_outputs.vpc_id
  subnet_ids = local.careerhub_subnets_outputs.private_subnet_ids
  region     = var.region

  project_id = module.mongodb_atlas_project.project_id
}

module "mongodb_atlas_cluster" {
  source = "../_modules/mongodb_atlas_cluster"

  project_id = module.mongodb_atlas_project.project_id
  name       = "${var.env}-careerhub"

  region = var.region
  depends_on = [
    module.mongodb_privatelink,
  ]
}

locals {
  users = { for user_arn in var.mongodb_admin_iam_user_arns : user_arn => {
    aws_iam_principal_arn = user_arn
    aws_iam_type          = "USER"
  } }
  roles = { for role_arn in var.mongodb_admin_iam_role_arns : role_arn => {
    aws_iam_principal_arn = role_arn
    aws_iam_type          = "ROLE"
  } }
}

module "mongodb_atlas_admin" {
  for_each = merge(local.users, local.roles)
  source   = "../_modules/mongodb_atlas_user"

  project_id = module.mongodb_atlas_project.project_id

  aws_iam_type          = each.value.aws_iam_type
  aws_iam_principal_arn = each.value.aws_iam_principal_arn

  roles = [
    {
      role_name     = "atlasAdmin"
      database_name = "admin"
    },
    {
      role_name     = "readWriteAnyDatabase"
      database_name = "admin"
    }
  ]
}



# data "aws_vpc" "careerhub" {
#   id = local.careerhub_subnets_outputs.vpc_id
# }

# module "mongodb_aws_network_peering" {
#   source = "../_modules/mongodb_aws_network_peering"

#   region           = var.region
#   project_id       = module.mongodb_atlas_project.project_id
#   vpc_id           = local.careerhub_subnets_outputs.vpc_id
#   atlas_cidr_block = "192.168.248.0/21"
#   vpc_cidr_block   = data.aws_vpc.careerhub.cidr_block
#   aws_account_id   = split(":", data.aws_vpc.careerhub.arn)[4]
# }

# # peering 생성 이후 조회되는 private endpoint 정보를 위해
# data "mongodbatlas_advanced_cluster" "this" {
#   project_id = module.mongodb_atlas_project.project_id
#   name       = module.mongodb_atlas_cluster.db_name

#   depends_on = [
#     module.mongodb_aws_network_peering,
#   ]
# }

