variable "juju_controller" {
  description = "The credentials to use when authenticating to the Juju controller."
  type = object({
    controller_addresses = list(string)
    username             = string
    password             = string
    ca_certificate       = string
    lazy_api_check       = bool
  })
  sensitive = true
}

variable "name" {
  description = "The name of the Juju model to create."
  type        = string
}

variable "cloud_name" {
  description = "The Juju cloud on which to create the model."
  type        = string
}
