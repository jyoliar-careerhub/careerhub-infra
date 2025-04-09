variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "mongodb_atlas_public_key" {
  type = string
}

variable "mongodb_atlas_private_key" {
  type      = string
  sensitive = true
}

variable "mongodb_admin_iam_user_arns" {
  type    = list(string)
  default = []
}

variable "mongodb_admin_iam_role_arns" {
  type    = list(string)
  default = []
}
