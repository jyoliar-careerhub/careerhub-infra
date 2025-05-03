variable "name" {
  type = string
}

variable "build_arch" {
  type = string
  validation {
    condition     = var.build_arch == "arm64" || var.build_arch == "x86_64"
    error_message = "build_arch must be either arm64 or x86_64"
  }
}

variable "repository_path" {
  type = string
}

variable "branch_name" {
  type = string
}


variable "vpc_id" {
  type = string
}


variable "subnet_arns" {
  type = list(string)
}

variable "connection_arn" {
  type = string
}
