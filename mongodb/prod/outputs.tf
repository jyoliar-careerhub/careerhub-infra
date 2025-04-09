output "mongodb_endpoint" {
  value = module.mongodb_atlas_cluster.mongodb_endpoint
}

output "admin_db_user_secret_id" {
  value = module.mongodb_atlas_project.admin_db_user_secret_id
}
