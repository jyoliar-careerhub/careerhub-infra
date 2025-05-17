resource "aws_rds_cluster_parameter_group" "connection_config" {
  name   = "${var.name}-conn-config"
  family = "aurora-mysql8.0"

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }

  parameter {
    name  = "wait_timeout"
    value = var.wait_timeout
  }
}

resource "aws_rds_cluster" "this" {
  cluster_identifier              = var.name
  engine                          = "aurora-mysql"
  engine_version                  = "8.0.mysql_aurora.3.08.0"
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.connection_config.name

  db_subnet_group_name        = aws_db_subnet_group.this.name
  vpc_security_group_ids      = [aws_security_group.this.id]
  master_username             = var.master_username
  manage_master_user_password = true
  database_name               = var.db_name
  skip_final_snapshot         = true

  // To enable serverless
  engine_mode = "provisioned"

  serverlessv2_scaling_configuration {
    max_capacity             = 32
    min_capacity             = 0
    seconds_until_auto_pause = 3600 # 1 hour
  }
}
resource "aws_rds_cluster_instance" "this" {
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = [for k, subnet_id in var.subnet_ids : subnet_id]
}

resource "aws_security_group" "this" {
  name   = "${var.name}-security-group"
  vpc_id = var.vpc_id
}
