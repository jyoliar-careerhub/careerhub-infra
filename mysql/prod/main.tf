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

data "aws_subnet" "this" {
  for_each = toset(concat(local.careerhub_subnets_outputs.private_subnet_ids, local.careerhub_subnets_outputs.public_subnet_ids))

  id = each.value
}

resource "aws_security_group_rule" "allow_mysql" {
  for_each = module.mysql

  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [for subnet in data.aws_subnet.this : subnet.cidr_block]
  ipv6_cidr_blocks  = [for subnet in data.aws_subnet.this : subnet.ipv6_cidr_block if subnet.ipv6_cidr_block != null && subnet.ipv6_cidr_block != ""]
  security_group_id = each.value.security_group_id
}
