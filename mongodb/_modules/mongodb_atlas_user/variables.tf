variable "project_id" {
  type = string
}

variable "roles" {
  type = list(object({
    role_name       = string
    database_name   = string
    collection_name = optional(string)
  }))
}

variable "aws_iam_type" {
  type = string
}

variable "aws_iam_principal_arn" {
  type = string
}
