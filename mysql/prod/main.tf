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
  for_each = concat(local.careerhub_subnets_outputs.private_subnet_ids, local.careerhub_subnets_outputs.public_subnet_ids)

  id = each.value
}

resource "aws_security_group_rule" "allow_mysql" {
  for_each = data.aws_subnet.this

  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [each.value.cidr_block]
  ipv6_cidr_blocks  = each.value.ipv6_cidr_block != null ? [each.value.ipv6_cidr_block] : []
  security_group_id = "sg-123456"
}
