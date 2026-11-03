include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = coalesce(try(values.module_source, null), try("git::https://github.com/canonical/terraform-juju-controller.git//modules/juju_cloud?ref=${values.module_ref}", null))
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

dependency "canonicalk8s" {
  config_path = try(values.canonicalk8s_path, null)

  mock_outputs_merge_strategy_with_state = "shallow"

  mock_outputs = {
    kubeconfig_path = "/path/to/kubeconfig"
  }
}

dependencies {
  paths = try(values.dependencies, [])
}

exclude {
  if      = coalesce(try(values.exclude, null), false)
  actions = ["all"]
}

inputs = merge(
  {
    # Optional inputs (only passed if defined in the stacks config)
    for k, v in {

      # Applies to clouds other than Kubernetes
      auth_types                    = try(values.auth_types, null)
      endpoint                      = try(values.endpoint, null)
      identity_endpoint             = try(values.identity_endpoint, null)
      storage_endpoint              = try(values.storage_endpoint, null)
      ca_certificates               = try(values.ca_certificates, null)
      regions                       = try(values.regions, null)
      target_controller             = try(values.target_controller, null)
      credentials                   = try(values.credentials, null)
      add_credentials_to_client     = try(values.add_credentials_to_client, null)
      add_credentials_to_controller = try(values.add_credentials_to_controller, null)

      # Kubernetes specific
      kubernetes_config             = try(coalesce(try(values.kubernetes_config, null), try(file(dependency.canonicalk8s.outputs.kubeconfig_path), null)), null)
      parent_cloud_name             = try(values.parent_cloud_name, null)
      parent_cloud_region           = try(values.parent_cloud_region, null)
      skip_service_account_creation = try(values.skip_service_account_creation, null)
      storage_class_name            = try(values.storage_class_name, null)
    } : k => v if v != null
  },
  {
    // Dependent variables
    juju_controller = coalesce(try(values.juju_controller, null), try(dependency.juju_bootstrap.outputs.juju_controller, null))

    // Required variables
    name = values.name
    type = values.type
})