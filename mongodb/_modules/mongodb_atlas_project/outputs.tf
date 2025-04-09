output "project_id" {
  value = mongodbatlas_project.this.id
}

output "admin_db_user_secret_id" {
  value = aws_secretsmanager_secret.admin_db_user.id
}
