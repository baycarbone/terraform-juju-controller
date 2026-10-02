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

variable "region" {
  description = "The name of the region in the cloud the model will be deployed to"
  type        = string
  default     = null
}

variable "credential" {
  description = "The name of the Juju credential to use for the model"
  type        = string
  default     = null
}

variable "config" {
  description = "The configuration for the Juju model"
  type        = map(string)
  default     = null
}

# set to null if creating a k8s model as ssh key is not needed in that scenario
variable "ssh_key_path" {
  description = "The path to the SSH key to use for the model"
  type        = string
  default     = null
}

variable "storage_pools" {
  description = "Storage pools to add to the model"
  type = list(object({
    name             = string
    storage_provider = string
    attributes       = map(string)
  }))
  default = null
}
