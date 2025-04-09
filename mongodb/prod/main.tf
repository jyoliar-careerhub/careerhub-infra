data "mongodbatlas_roles_org_id" "current" {
}

module "mongodb_atlas_project" {
  source = "../_modules/mongodb_atlas_project"

  name = "${var.env}-careerhub"

  organization_id = data.mongodbatlas_roles_org_id.current.id
}

module "mongodb_atlas_cluster" {
  source = "../_modules/mongodb_atlas_cluster"

  project_id = module.mongodb_atlas_project.project_id
  name       = "${var.env}-careerhub"

  region = var.region
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
