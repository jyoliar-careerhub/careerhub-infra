terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
    }
  }
}

provider "aws" {
  default_tags {
    tags = var.default_tags
  }

  region = var.region
}
