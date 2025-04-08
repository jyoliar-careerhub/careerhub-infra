locals {
  mysqls = {
    "user" = {}
  }
}

module "mysql" {
  for_each = local.mysqls

  source = "../_modules/aurora"
  name   = "${var.env}-${each.key}"

  vpc_id     = local.careerhub_subnets_outputs.vpc_id
  subnet_ids = local.careerhub_subnets_outputs.private_subnet_ids
}
