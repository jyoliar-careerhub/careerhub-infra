variable "name" {
  type = string
}

variable "organization_id" {
  type = string
}

variable "admin_db_username" {
  type    = string
  default = "admin"
}

variable "tags" {
  type    = map(string)
  default = {}
}
