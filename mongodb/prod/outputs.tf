output "project_id" {
  value = module.mongodb_atlas_project.project_id
}

output "mongodb_database_name" {
  value = module.mongodb_atlas_cluster.db_name
}

output "mongodb_private_endpoint" {
  value = data.mongodbatlas_advanced_cluster.this.connection_strings[0].private_srv
}
