variable "name" {
  type = string
}

variable "db_name" {
  description = "The name of the database. If not specified, the value of the 'name' variable will be used."
  type        = string
  default     = ""
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}


### Optional variables
variable "master_username" {
  type    = string
  default = "admin"
}

variable "max_connections" {
  description = "The maximum number of connections to the database."
  type        = number
  default     = 100
}

variable "wait_timeout" {
  description = "The number of seconds the server waits for activity on a non-interactive connection before closing it."
  type        = number
  default     = 600
}
