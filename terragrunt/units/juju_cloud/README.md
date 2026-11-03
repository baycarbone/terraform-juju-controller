# juju_cloud Terragrunt unit

This unit wraps the `modules/juju_cloud` Terraform module for use from a Terragrunt stack.

Default source: `git::https://github.com/canonical/terraform-juju-controller.git//modules/juju_cloud?ref=<module_ref>`.
A custom module source can be provided via the optional `values.module_source` entry, which takes precedence over the default.

The enclosing stack is meant to provide a `values.juju_cloud` attribute, which is used to populate the module source version, dependencies, required inputs, and any optional inputs.

## Expected stack-provided values

Required `values` entries:

- `name`
- `type`

One of the following must be present (otherwise the module source cannot be resolved):

- `module_ref` — used with the default git source
- `module_source` — a full custom module source, takes precedence over the default

Optional `values` entries:

- `exclude`
- `dependencies`
- `juju_bootstrap_path`
- `juju_controller`

Applies to clouds other than Kubernetes (`type != "kubernetes"`):

- `auth_types`
- `endpoint`
- `identity_endpoint`
- `storage_endpoint`
- `ca_certificates`
- `regions`
- `target_controller`
- `credentials`
- `add_credentials_to_client`
- `add_credentials_to_controller`

Kubernetes specific (`type == "kubernetes"`):

- `canonicalk8s_path`
- `kubernetes_config`
- `parent_cloud_name`
- `parent_cloud_region`
- `skip_service_account_creation`
- `storage_class_name`

## Behavior

- The module source is taken from `values.module_source` when set; otherwise it defaults to `git::https://github.com/canonical/terraform-juju-controller.git//modules/juju_cloud?ref=<module_ref>`, which requires `values.module_ref` to be set. At least one of `module_source` or `module_ref` must be provided.
- A Terragrunt dependency on the `juju_bootstrap` unit is declared at `values.juju_bootstrap_path` when set, with mock outputs used for planning before the controller exists.
- A Terragrunt dependency on the `canonicalk8s` unit is declared at `values.canonicalk8s_path` when set, with a mock `kubeconfig_path` output used for planning.
- Terragrunt dependencies are populated from `values.dependencies` when present.
- The unit is excluded from all Terragrunt actions when `values.exclude` is `true`.
- `juju_controller` is taken from `values` when set, otherwise it falls back to the `juju_bootstrap` unit's outputs.
- `kubernetes_config` is taken from `values` when set, otherwise it falls back to reading the kubeconfig file from the `canonicalk8s` unit's `kubeconfig_path` output.
- Optional inputs are forwarded only when the corresponding `values` entry is not `null`:
  - Non-Kubernetes clouds (`auth_types`, `endpoint`, `identity_endpoint`, `storage_endpoint`, `ca_certificates`, `regions`, `target_controller`, `credentials`, `add_credentials_to_client`, `add_credentials_to_controller`) must not be set for Kubernetes clouds, as the module validates them to be `null` when `type == "kubernetes"`.
  - Kubernetes-specific inputs (`kubernetes_config`, `parent_cloud_name`, `parent_cloud_region`, `skip_service_account_creation`, `storage_class_name`) must not be set for non-Kubernetes clouds, except `storage_class_name` which the module requires to be `null` unless `type == "kubernetes"`.

## Reference

For the definition of the forwarded inputs and module outputs, see `modules/juju_cloud/README.md`.