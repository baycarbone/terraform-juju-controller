include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = coalesce(try(values.module_source, null), try("git::https://github.com/canonical/terraform-juju-controller.git//modules/juju-model?ref=${values.module_ref}", null))
}

dependency "juju_bootstrap" {
  config_path = try(values.juju_bootstrap_path, null)

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

dependencies {
  paths = try(values.dependencies, [])
}

exclude {
  if      = try(values.exclude, false)
  actions = ["all"]
}

inputs = merge({
  // Optional inputs (only passed if defined in the stacks config)
  for k, v in {
    region        = try(values.region, null)
    config        = try(values.config, null)
    ssh_key_path  = try(values.ssh_key_path, null)
    storage_pools = try(values.storage_pools, null)
  } : k => v
  if v != null
  },
  {
    // Dependent variables
    juju_controller = coalesce(try(values.juju_controller, null), try(dependency.juju_bootstrap.outputs.juju_controller, null))
    cloud_name      = coalesce(try(values.cloud_name, null), try(dependency.juju_bootstrap.outputs.juju_cloud, null))
    credential      = coalesce(try(values.credential, null), try(dependency.juju_bootstrap.outputs.juju_cloud, null))

    // Required variables
    name = values.model_name
})
