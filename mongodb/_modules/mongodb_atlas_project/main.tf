resource "mongodbatlas_project" "this" {
  name   = var.name
  org_id = var.organization_id


  is_collect_database_specifics_statistics_enabled = true
  is_data_explorer_enabled                         = true
  is_extended_storage_sizes_enabled                = true
  is_performance_advisor_enabled                   = true
  is_realtime_performance_panel_enabled            = true
  is_schema_advisor_enabled                        = true
}

resource "mongodbatlas_database_user" "admin_db_user" {
  project_id = mongodbatlas_project.this.id
  username   = var.admin_db_username

  auth_database_name = "admin"

  roles {
    role_name     = "atlasAdmin"
    database_name = "admin"
  }
  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }
}

resource "aws_secretsmanager_secret" "admin_db_user" {
  name                           = "${var.name}-admin-db-user"
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "admin_db_user" {
  secret_id = aws_secretsmanager_secret.admin_db_user.id
  secret_string = jsonencode({
    username = mongodbatlas_database_user.admin_db_user.username
    password = mongodbatlas_database_user.admin_db_user.password
  })
}
