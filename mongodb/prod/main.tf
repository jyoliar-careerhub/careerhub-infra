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

