output "private_endpoint" {
  value = mongodbatlas_advanced_cluster.this.connection_strings[0].private_endpoint
}

output "db_name" {
  value = mongodbatlas_advanced_cluster.this.name
}

output "container_id" {
  value = one(values(mongodbatlas_advanced_cluster.this.replication_specs[0].container_id))
}
