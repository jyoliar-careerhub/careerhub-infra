provider "aws" {
  default_tags {
    tags = var.default_tags
  }

  region = var.region
}
