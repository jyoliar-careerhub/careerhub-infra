variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}
variable "region" {
  type = string
}

variable "project_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}
