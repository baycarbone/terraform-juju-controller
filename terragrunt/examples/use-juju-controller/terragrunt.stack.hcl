locals {
  common = read_terragrunt_config("${get_repo_root()}/terragrunt/examples/_lxd_common.hcl")
}

unit "controller" {
  source = "${get_repo_root()}/terragrunt/units/juju_bootstrap"
  path   = "controller"

  values = local.common.locals.values
}

unit "juju_model" {
  source = "${get_repo_root()}/terragrunt/units/juju-model"

  path = "juju-model"

  values = {
    version             = "main"
    module_source       = "${get_repo_root()}/modules/juju-model"
    juju_bootstrap_path = "../controller"
    model_name          = "default-model"
  }
}
