# juju_bootstrap Terragrunt unit

This unit wraps the root Terraform module for use from a Terragrunt stack.

Default source: `tfr:///juju/controller/juju?version=<module_ref>` (Terraform Registry), pinned to the version from `values.module_ref`.
A custom module source can be provided via the optional `values.module_source` entry, which takes precedence over the default.
The `examples/lxd-ci` example overrides this with `${get_repo_root()}` for CI testing against the local module.

The enclosing stack is meant to provide a `values.juju_bootstrap` attribute, which is used to populate the module source version, dependencies, required inputs, and any optional inputs.

## Expected stack-provided values

Required `values` entries:

- `module_ref`
- `name`
- `cloud`
- `cloud_credential`
- `controller_num_units`

Optional `values` entries:

- `module_source`
- `exclude`
- `dependencies`
- `path_juju_binary`
- `agent_version`
- `bootstrap_base`
- `bootstrap_config`
- `bootstrap_constraints`
- `controller_config`
- `controller_model_config`
- `destroy_flags`
- `model_constraints`
- `model_default`
- `storage_pool`

## Behavior

- The module source is taken from `values.module_source` when set, otherwise it defaults to `tfr:///juju/controller/juju?version=<module_ref>`.
- Terragrunt dependencies are populated from `values.dependencies` when present.
- The unit is excluded from all Terragrunt actions when `values.exclude` is `true`.
- Optional module inputs are forwarded only when the corresponding `values` entry is not `null`.

## Reference

For the definition of the forwarded inputs and module outputs, see the root `README.md`.
