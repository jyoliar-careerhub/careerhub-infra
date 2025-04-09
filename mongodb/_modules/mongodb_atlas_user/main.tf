resource "mongodbatlas_database_user" "this" {
  project_id = var.project_id
  username   = var.aws_iam_principal_arn

  auth_database_name = "$external"
  aws_iam_type       = var.aws_iam_type

  dynamic "roles" {
    for_each = var.roles
    content {
      role_name       = roles.value.role_name
      database_name   = roles.value.database_name
      collection_name = roles.value.collection_name
    }
  }
}
