variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "atlas_public_key" {
  type = string
}

variable "atlas_private_key" {
  type      = string
  sensitive = true
}
