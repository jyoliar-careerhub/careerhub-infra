variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "default_tags" {
  type = map(string)
}

variable "mongodb_atlas_public_key" {
  type = string
}

variable "mongodb_atlas_private_key" {
  type      = string
  sensitive = true
}
