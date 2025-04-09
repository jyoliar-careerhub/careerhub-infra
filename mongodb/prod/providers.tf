provider "aws" {
  default_tags {
    tags = {
      env = var.env
    }
  }

  region = var.region
}

provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}
