terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.31.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}
