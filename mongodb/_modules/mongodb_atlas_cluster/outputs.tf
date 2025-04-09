output "mongodb_endpoint" {
  value = mongodbatlas_advanced_cluster.this.connection_strings[0].private_endpoint
}
