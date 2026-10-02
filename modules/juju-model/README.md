# juju-model

This module creates a Juju model on an existing Juju controller and optionally adds an SSH key to it.

## Usage

```hcl
module "juju_model" {
  source = "git::https://github.com/canonical/terraform-juju-controller.git//modules/juju-model?ref=<ref>"

  juju_controller = {
    controller_addresses = ["..."]
    username             = "..."
    password             = "..."
    ca_certificate       = "..."
    lazy_api_check       = false
  }

  name       = "my-model"
  cloud_name = "localhost"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.x |
| juju provider | >= 0.x |

## Providers

| Name | Version |
|------|---------|
| juju | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| juju_controller | The credentials to use when authenticating to the Juju controller. | `object({ controller_addresses = list(string), username = string, password = string, ca_certificate = string, lazy_api_check = bool })` | n/a | yes |
| name | The name of the Juju model to create. | `string` | n/a | yes |
| cloud_name | The Juju cloud on which to create the model. | `string` | n/a | yes |
| region | The name of the region in the cloud the model will be deployed to. | `string` | `null` | no |
| credential | The name of the Juju credential to use for the model. | `string` | `null` | no |
| config | The configuration for the Juju model. | `map(string)` | `null` | no |
| ssh_key_path | The path to the SSH key to use for the model. Set to `null` when creating a k8s model, as an SSH key is not needed in that scenario. | `string` | `null` | no |
| storage_pools | Storage pools to add to the model. | `list(object({ name = string, storage_provider = string, attributes = map(string) }))` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| name | The name of the Juju model. |
| uuid | The UUID of the Juju model. |
| cloud | The name of the cloud the model is deployed to. |

## Notes

- The `juju_controller` input is marked as sensitive.
- When `ssh_key_path` is set, a `juju_ssh_key` resource is created to add the key to the model.
