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
    name = var.cloud_name
  }
}
