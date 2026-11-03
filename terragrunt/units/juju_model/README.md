# juju_model Terragrunt unit

This unit wraps the `modules/juju_model` Terraform module for use from a Terragrunt stack.

Default source: `git::https://github.com/canonical/terraform-juju-controller.git//modules/juju_model?ref=<module_ref>`.
A custom module source can be provided via the optional `values.module_source` entry, which takes precedence over the default.

The enclosing stack is meant to provide a `values.juju_model` attribute, which is used to populate the module source version, dependencies, required inputs, and any optional inputs.

## Expected stack-provided values

Required `values` entries:

- `model_name`

One of the following must be present (otherwise the module source cannot be resolved):

- `module_ref` — used with the default git source
- `module_source` — a full custom module source, takes precedence over the default

Optional `values` entries:

- `exclude`
- `dependencies`
- `juju_bootstrap_path`
- `juju_cloud_path`
- `juju_controller`
- `cloud_name`
- `region`
- `credential`
- `config`
- `ssh_key_path`
- `storage_pools`

## Behavior

- The module source is taken from `values.module_source` when set; otherwise it defaults to `git::https://github.com/canonical/terraform-juju-controller.git//modules/juju_model?ref=<module_ref>`, which requires `values.module_ref` to be set. At least one of `module_source` or `module_ref` must be provided.
- A Terragrunt dependency on the `juju_bootstrap` unit is declared at `values.juju_bootstrap_path` when set, with mock outputs used for planning before the controller exists.
- A Terragrunt dependency on the `juju_cloud` unit is declared at `values.juju_cloud_path` when set, with mock `name` and `region` outputs used for planning before the cloud exists.
- Terragrunt dependencies are populated from `values.dependencies` when present.
- The unit is excluded from all Terragrunt actions when `values.exclude` is `true`.
- `juju_controller` is taken from `values` when set, otherwise it falls back to the `juju_bootstrap` unit's outputs.
- `cloud_name` and `credential` are taken from `values` when set, otherwise they fall back to the `juju_cloud` unit's `name` output, then to the `juju_bootstrap` unit's outputs.
- `region` is taken from `values` when set, otherwise it falls back to the `juju_cloud` unit's `region` output, then to the `juju_bootstrap` unit's `juju_cloud_region` output.
- Optional module inputs (`config`, `ssh_key_path`, `storage_pools`) are forwarded only when the corresponding `values` entry is not `null`.

## Reference

For the definition of the forwarded inputs and module outputs, see `modules/juju_model/README.md`.
