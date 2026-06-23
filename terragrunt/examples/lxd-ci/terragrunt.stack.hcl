locals {
  common = read_terragrunt_config("${get_repo_root()}/terragrunt/examples/_lxd_common.hcl")
}

unit "controller" {
  source = "${get_repo_root()}/terragrunt/units/juju_bootstrap"
  path   = "controller"

  values = merge(local.common.locals.values, {
    source = "${get_repo_root()}"
  })
}
