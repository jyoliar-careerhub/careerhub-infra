output "endpoint" {
  description = "The endpoint of the Aurora cluster."
  value       = aws_rds_cluster.this.endpoint
}

output "port" {
  description = "The port of the Aurora cluster."
  value       = aws_rds_cluster.this.port
}

output "user_secret_arn" {
  value = aws_rds_cluster.this.master_user_secret[0].secret_arn
}
