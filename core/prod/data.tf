locals {
  careerhub_subnets_ws = "${var.env}-careerhub-subnets"
  # mongodb_ws           = "${var.env}-mongodb"
  # mysql_ws             = "${var.env}-mysql"
}

module "remote_state" {
  source = "../../_modules/tfc_remote_state"

  workspaces = [local.careerhub_subnets_ws,
    # local.mongodb_ws, local.mysql_ws
  ]
}

locals {
  careerhub_subnets_outputs = module.remote_state.outputs[local.careerhub_subnets_ws]
  # mongodb_outputs           = module.remote_state.outputs[local.mongodb_ws]
  # mysql_outputs             = module.remote_state.outputs[local.mysql_ws]
}
