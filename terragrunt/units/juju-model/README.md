# juju-model Terragrunt unit

This unit wraps the `modules/juju-model` Terraform module for use from a Terragrunt stack.

Default source: `git::https://github.com/canonical/terraform-juju-controller.git//modules/juju-model?ref=<module_ref>`.
A custom module source can be provided via the optional `values.module_source` entry, which takes precedence over the default.

The enclosing stack is meant to provide a `values.juju_model` attribute, which is used to populate the module source version, dependencies, required inputs, and any optional inputs.

## Expected stack-provided values

Required `values` entries:

- `module_ref`
- `model_name`

Optional `values` entries:

- `module_source`
- `exclude`
- `dependencies`
- `juju_bootstrap_path`
- `juju_controller`
- `cloud_name`
- `region`
- `credential`
- `config`
- `ssh_key_path`

## Behavior

- The module source is taken from `values.module_source` when set, otherwise it defaults to `git::https://github.com/canonical/terraform-juju-controller.git//modules/juju-model?ref=<module_ref>`.
- A Terragrunt dependency on the `juju_bootstrap` unit is declared at `values.juju_bootstrap_path` when set, with mock outputs used for planning before the controller exists.
- Terragrunt dependencies are populated from `values.dependencies` when present.
- The unit is excluded from all Terragrunt actions when `values.exclude` is `true`.
- `juju_controller` and `cloud_name` are taken from `values` when set, otherwise they fall back to the `juju_bootstrap` unit's outputs.
- Optional module inputs (`region`, `credential`, `config`, `ssh_key_path`) are forwarded only when the corresponding `values` entry is not `null`.

## Reference

For the definition of the forwarded inputs and module outputs, see `modules/juju-model/README.md`.
