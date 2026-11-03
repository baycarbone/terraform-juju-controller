provider "juju" {
  controller_addresses = join(",", var.juju_controller.controller_addresses)
  username             = var.juju_controller.username
  password             = var.juju_controller.password
  ca_certificate       = var.juju_controller.ca_certificate
  lazy_api_check       = var.juju_controller.lazy_api_check
}

resource "juju_cloud" "cloud" {
  count = var.type != "kubernetes" ? 1 : 0

  name              = var.name
  type              = var.type
  auth_types        = var.auth_types
  endpoint          = var.endpoint
  identity_endpoint = var.identity_endpoint
  storage_endpoint  = var.storage_endpoint
  ca_certificates   = var.ca_certificates
  regions           = var.regions
  target_controller = var.target_controller
}

resource "juju_credential" "cloud_credentials" {
  count = var.type != "kubernetes" ? 1 : 0

  name = "${var.name}_cred"
  cloud {
    name = juju_cloud.cloud[0].name
  }
  auth_type             = tolist(var.auth_types)[0]
  attributes            = var.credentials
  client_credential     = var.add_credentials_to_client
  controller_credential = var.add_credentials_to_controller
}

resource "juju_kubernetes_cloud" "cloud" {
  count = var.type == "kubernetes" ? 1 : 0

  name                          = var.name
  kubernetes_config             = var.kubernetes_config
  parent_cloud_name             = var.parent_cloud_name
  parent_cloud_region           = var.parent_cloud_region
  skip_service_account_creation = var.skip_service_account_creation
  storage_class_name            = var.storage_class_name
}
