output "endpoint" {
  description = "The endpoint of the Aurora cluster."
  value       = module.mysql["user"].endpoint
}

output "port" {
  description = "The port of the Aurora cluster."
  value       = module.mysql["user"].port
}

output "security_group_id" {
  description = "The security group ID of the Aurora cluster."
  value       = module.mysql["user"].security_group_id
}


output "user_secret_arn" {
  value = module.mysql["user"].user_secret_arn
}
