terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.31.0"
    }
  }
}


provider "mongodbatlas" {
  public_key  = var.mongodb_atlas_public_key
  private_key = var.mongodb_atlas_private_key
}

provider "aws" {
  region = var.region
  default_tags {
    tags = var.default_tags
  }
}
