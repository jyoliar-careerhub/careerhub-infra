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


data "aws_vpc" "this" {
  id = local.careerhub_subnets_outputs.vpc_id
}

resource "aws_security_group_rule" "allow_mysql" {
  for_each = module.mysql

  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.this.cidr_block]
  security_group_id = each.value.security_group_id
}

import {
  to = aws_security_group_rule.allow_mysql["user"]
  id = "sg-0a4679cb65807b429_ingress_tcp_3306_3306_10.0.0.0/16"
}
