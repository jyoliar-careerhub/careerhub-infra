
resource "mongodbatlas_database_user" "this" {
  project_id = var.project_id
  username   = var.role_arn

  auth_database_name = "$external"
  aws_iam_type       = "ROLE"

  roles {
    role_name       = "readWrite"
    database_name   = var.database_name
    collection_name = var.collection_name
  }
}
