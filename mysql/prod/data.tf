locals {
  careerhub_subnets_ws = "${var.env}-careerhub-subnets"
}

module "remote_state" {
  source = "../../_modules/tfc_remote_state"

  workspaces = [local.careerhub_subnets_ws]
}

locals {
  careerhub_subnets_outputs = module.remote_state.outputs[local.careerhub_subnets_ws]
}
