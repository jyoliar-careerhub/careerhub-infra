locals {
  careerhub_subnets_ws = "${var.env}-careerhub-subnets"
  mysql_ws             = "${var.env}-careerhub-mysql"
  eks_ws               = "${var.env}-eks"
}

module "remote_state" {
  source = "../../_modules/tfc_remote_state"

  workspaces = [
    local.careerhub_subnets_ws,
    local.mysql_ws,
    local.eks_ws,
  ]
}

locals {
  careerhub_subnets_outputs = module.remote_state.outputs[local.careerhub_subnets_ws]
  mysql_outputs             = module.remote_state.outputs[local.mysql_ws]
  eks_outputs               = module.remote_state.outputs[local.eks_ws]
}
