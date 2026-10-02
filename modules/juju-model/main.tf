provider "juju" {
  controller_addresses = join(",", var.juju_controller.controller_addresses)
  username             = var.juju_controller.username
  password             = var.juju_controller.password
  ca_certificate       = var.juju_controller.ca_certificate
  lazy_api_check       = var.juju_controller.lazy_api_check
}

resource "juju_model" "model" {
  name = var.name

  cloud {
    name   = var.cloud_name
    region = var.region
  }

  credential = var.credential
  config     = var.config
}

resource "juju_storage_pool" "storage_pool" {
  for_each = var.storage_pools != null ? { for sp in var.storage_pools : sp.name => sp } : {}

  model_uuid       = juju_model.model.uuid
  name             = each.value.name
  storage_provider = each.value.storage_provider
  attributes       = each.value.attributes
}

resource "juju_ssh_key" "model_ssh_key" {
  count      = var.ssh_key_path != null ? 1 : 0 # if null, it means we are creating a k8s model in which case an ssh key is not needed
  model_uuid = juju_model.model.uuid
  payload    = trimspace(file(var.ssh_key_path))
}