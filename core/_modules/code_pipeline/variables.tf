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

variable "codebuild_role_arn" {
  type = string
}

variable "codepipeline_role_arn" {
  type = string

}

variable "region" {
  type = string
}

variable "codebuild_bucket_id" {
  type = string

}

variable "codebuild_bucket" {
  type = string
}

variable "codebuild_sg_id" {
  type = string
}
