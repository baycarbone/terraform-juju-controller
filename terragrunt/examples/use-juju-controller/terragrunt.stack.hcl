locals {
  common = read_terragrunt_config("${get_repo_root()}/terragrunt/examples/_lxd_common.hcl")
}

unit "controller" {
  source = "${get_repo_root()}/terragrunt/units/juju_bootstrap"
  path   = "controller"

  values = local.common.locals.values
}

unit "juju_model" {
  source = "${get_repo_root()}/terragrunt/units/juju_model"

  path = "juju_model"

  values = {
    module_source       = "${get_repo_root()}/modules/juju_model"
    juju_bootstrap_path = "../controller"
    model_name          = "default-model"
  }
}
