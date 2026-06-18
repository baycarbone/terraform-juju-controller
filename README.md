# terraform-juju-controller

Terraform module and Terragrunt unit to bootstrap a [Juju](https://juju.is) controller.

## Layout

```
modules/juju_bootstrap            # Terraform module that bootstraps a Juju controller
terragrunt/units/juju_bootstrap   # Terragrunt unit wrapping the module (used from a stack)
terragrunt/examples/lxd-ci        # Working LXD example exercised by CI
```

## Requirements

- Terraform / OpenTofu
- [`juju/juju`](https://registry.terraform.io/providers/juju/juju/latest) provider `> 1.3`
- Juju CLI

## Module: `modules/juju_bootstrap`

Bootstraps a Juju controller and, when `controller_num_units > 1`, enables HA.

Inputs and outputs map directly onto the `juju_controller` resource. For the
authoritative reference, see the upstream docs:
[Bootstrap a controller](https://canonical.com/juju/docs/terraform-provider-juju/2.0/howto/manage-controllers/#bootstrap-a-controller).

### Usage (direct Terraform)

```hcl
locals {
  lxd = yamldecode(file(pathexpand("~/lxd-credentials.yaml")))
}

module "controller" {
  source = "./modules/juju_bootstrap"

  name                 = "ci-lxd-controller"
  controller_num_units = 1

  cloud = {
    name       = "localhost"
    type       = "lxd"
    auth_types = ["certificate"]
  }

  cloud_credential = {
    name      = "lxd-cred"
    auth_type = "certificate"
    attributes = {
      server-cert = local.lxd["server-cert"]
      client-cert = local.lxd["client-cert"]
      client-key  = local.lxd["client-key"]
    }
  }

  # Optional
  bootstrap_base = "ubuntu@24.04"
}
```

See `modules/juju_bootstrap/variables.tf` and `outputs.tf` for the full input/output set.

## Terragrunt unit: `terragrunt/units/juju_bootstrap`

The unit wraps the module for use inside a stack. The enclosing stack must provide a
`values` attribute, which sets the pinned module `version`, the required inputs, and any
optional inputs (forwarded only when non-`null`).

```hcl
values = {
  # Required
  version              = "v1.4.3"
  name                 = "my-controller"
  controller_num_units = 1

  cloud = {
    name       = "localhost"
    type       = "lxd"
    auth_types = ["certificate"]
  }

  cloud_credential = {
    name      = "lxd-cred"
    auth_type = "certificate"
    attributes = { server-cert = "...", client-cert = "...", client-key = "..." }
  }

  # Optional
  dependencies   = []
  bootstrap_base = "ubuntu@24.04"
}
```

## Example: `terragrunt/examples/lxd-ci`

Bootstraps an LXD controller named `ci-lxd-controller`, reading credentials from
`~/lxd-credentials.yaml`. This is the example run by CI.

```sh
cd terragrunt/examples/lxd-ci
terragrunt apply --auto-approve
terragrunt destroy --auto-approve
```

CI runs, in order: set up LXD + Juju, write `~/lxd-credentials.yaml`, build/install the
provider, then `apply` and `destroy` the example above.

## High availability

`controller_num_units > 1` enables HA via a `local-exec` provisioner. Set
`path_juju_binary` if the Juju CLI is not at the default path.
