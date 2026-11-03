# juju_cloud

This module adds a cloud to a Juju controller and, for non-Kubernetes clouds, creates an associated credential. For Kubernetes clouds, it registers a k8s cluster as a cloud using a kubeconfig file.

## Usage

### Non-Kubernetes cloud (e.g. LXD)

```hcl
module "juju_cloud" {
  source = "git::https://github.com/canonical/terraform-juju-controller.git//modules/juju_cloud?ref=<ref>"

  name       = "localhost"
  type       = "lxd"
  auth_types = ["interactive", "certificate"]
  endpoint   = "https://127.0.0.1:8443"
  ca_certificates = [file("${get_repo_root()}/certs/chain.crt")]
  regions = [
    { name = "localhost" }
  ]

  credentials = {
    client-cert     = "..."
    client-key      = "..."
    server-cert     = "..."
  }
}
```

### Kubernetes cloud

```hcl
module "juju_cloud" {
  source = "git::https://github.com/canonical/terraform-juju-controller.git//modules/juju_cloud?ref=<ref>"

  name                = "my-k8s"
  type                = "kubernetes"
  kubernetes_config   = "/path/to/kubeconfig"
  storage_class_name  = "standard"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6 |
| juju provider | >= 1.0.0, < 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| juju | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | The name of the cloud in Juju. | `string` | n/a | yes |
| type | The type of the cloud. | `string` | n/a | yes |
| auth_types | List of supported authentication types by the cloud. Required for non-Kubernetes clouds; must be `null` for Kubernetes clouds. | `set(string)` | `null` | no |
| ca_certificates | List of PEM-encoded X509 certificates for the cloud. | `set(string)` | `null` | no |
| endpoint | Global endpoint for the cloud. | `string` | `null` | no |
| identity_endpoint | Global identity endpoint for the cloud. | `string` | `null` | no |
| storage_endpoint | Global storage endpoint for the cloud. | `string` | `null` | no |
| regions | List of regions for the cloud. The first region in the list is the default region for the cloud. | `list(object({ name = string, endpoint = optional(string), identity_endpoint = optional(string), storage_endpoint = optional(string) }))` | `[]` | no |
| target_controller | Only useful with JAAS - the backing controller where the cloud will be added. Required when running against a JAAS controller and must not be set otherwise. Changing this value will cause the cloud to be destroyed and recreated. | `string` | `null` | no |
| credentials | Credential attributes for the cloud. Required for non-Kubernetes clouds; must be `null` for Kubernetes clouds. | `map(string)` | `null` | no |
| add_credentials_to_client | Add credentials to the client. | `bool` | `true` | no |
| add_credentials_to_controller | Add credentials to the controller. | `bool` | `true` | no |
| kubernetes_config | The kubeconfig file path for the cloud. Cloud credentials will be added to the Juju controller for you. | `string` | `null` | no |
| parent_cloud_name | The parent cloud name, for adding a k8s cluster from an existing cloud. Changing this value will cause the cloud to be destroyed and recreated. Must be set when running against a JAAS controller. | `string` | `null` | no |
| parent_cloud_region | The parent cloud region name, for adding a k8s cluster from an existing cloud. Changing this value will cause the cloud to be destroyed and recreated. Must be set when running against a JAAS controller. | `string` | `null` | no |
| skip_service_account_creation | If `true`, the provider will not create a service account and role within the K8s cluster and will not override the authentication info in the K8s config, so it does not need to connect to the K8s API when adding a k8s cloud. | `bool` | `true` | no |
| storage_class_name | Specify the Kubernetes storage class name for workload and operator storage. Required for Kubernetes clouds. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| name | The name of the cloud in Juju. |
| region | The name of the default region in the cloud. |

## Notes

- For non-Kubernetes clouds, a `juju_cloud` resource and a `juju_credential` resource are created; the credential is named `<cloud_name>_cred` and uses the first entry of `auth_types`.
- For Kubernetes clouds (`type = "kubernetes"`), only a `juju_kubernetes_cloud` resource is created.
- The `credentials` and `kubernetes_config` inputs are marked as sensitive.
- `auth_types` and `credentials` are validated: they must be set for non-Kubernetes clouds and must be `null` for Kubernetes clouds. `storage_class_name` must be set for Kubernetes clouds and must be `null` otherwise.