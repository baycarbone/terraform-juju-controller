include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = values.module_source
}

dependency "juju_bootstrap" {
  config_path = values.juju_bootstrap_path

  mock_outputs_merge_strategy_with_state = "shallow"

  mock_outputs = {
    juju_cloud = "mock-cloud-name"
    juju_controller = {
      lazy_api_check       = true
      controller_addresses = ["mock-controller-address"]
      username             = "mock-username"
      password             = "mock-password"
      ca_certificate       = "mock-ca-certificate"
    }
  }
}

inputs = {
  juju_controller = merge(
    dependency.juju_bootstrap.outputs.juju_controller,
    { lazy_api_check = false }
  )
  cloud_name      = dependency.juju_bootstrap.outputs.juju_cloud
  name            = values.model_name
}
