# terraform-juju-controller

Terraform module and Terragrunt unit to bootstrap a [Juju](https://juju.is) controller.

## What it does

- Configures the `juju` provider in `controller_mode`.
- Creates a `juju_controller` resource with configurable cloud, credential, and bootstrap settings.
- Optionally runs `juju enable-ha` using a `local-exec` provisioner when `controller_num_units > 1`.

## Layout

```
.                                  # Root module (primary entrypoint)
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── terragrunt/
│   ├── units/juju_bootstrap/      # Terragrunt unit wrapping the module
│   └── examples/lxd-ci/           # Working LXD example exercised by CI
└── tools/
    └── create_lxd_config.sh       # Helper to extract LXD credentials
```

## Requirements

- Terraform / OpenTofu 1.12+
- [`juju/juju`](https://registry.terraform.io/providers/juju/juju/latest) provider `> 1.3`
- Juju CLI available on the machine running apply

## Usage

The module bootstraps a Juju controller and, when `controller_num_units > 1`, enables HA.
Inputs and outputs map directly onto the `juju_controller` resource. For the authoritative
reference, see the upstream docs:
[Bootstrap a controller](https://canonical.com/juju/docs/terraform-provider-juju/2.0/howto/manage-controllers/#bootstrap-a-controller).

### Direct Terraform

```hcl
locals {
  lxd = yamldecode(file(pathexpand("~/lxd-credentials.yaml")))
}

module "controller" {
  source = "./"

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

See `variables.tf` and `outputs.tf` for the full input/output set.

### LXD cloud

```hcl
module "juju_bootstrap_example" {
  source = "juju/juju-controller/juju"

  name = "my-controller"

  cloud = {
    auth_types = ["certificate"]
    name       = "lxd-cloud"
    type       = "lxd"
    endpoint   = "https://10.0.0.1:8443"
    region = {
      name     = "default"
      endpoint = "https://10.0.0.1:8443"
    }
  }

  cloud_credential = {
    auth_type = "interactive"
    name      = "lxd-token"
    attributes = {
      trust-token = trimspace(file("/path/to/token"))
    }
  }

  controller_num_units = 3
}
```

### MAAS cloud

```hcl
module "juju_bootstrap_example" {
  source = "juju/juju-controller/juju"

  name = "my-controller"

  cloud = {
    auth_types = ["oauth1"]
    type       = "maas"
    name       = "maas-cloud"
    endpoint   = "http://10.0.0.1:5240/MAAS/"
  }

  cloud_credential = {
    auth_type = "oauth1"
    name      = "maas-creds"
    attributes = {
      maas-oauth = trimspace(file("/path/to/maas_api_key"))
    }
  }

  controller_num_units = 3
}
```

### Example of controller_model_config or model_default

```
controller_model_config = {
  default-base     = "ubuntu@22.04"
  lxd-snap-channel = "5.0/stable"
  cloudinit-userdata = <<EOT
#cloud-config

ca-certs:
  trusted:
  - |
    -----BEGIN CERTIFICATE-----
    ROOT CA
    -----END CERTIFICATE-----
    -----BEGIN CERTIFICATE-----
    INTERMEDIATE CA
    -----END CERTIFICATE-----
EOT
}
```

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

## Notes

- HA enablement is implemented with `terraform_data` + `local-exec` and Juju CLI commands
  as opposed to Terraform actions to ensure compatibility with OpenTofu, as actions are
  not yet supported. See <https://github.com/opentofu/opentofu/issues/3309>.
