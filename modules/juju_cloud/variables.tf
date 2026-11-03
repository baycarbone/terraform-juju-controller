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
  description = "The name of the cloud in Juju."
  type        = string
}

variable "type" {
  description = "The type of the cloud."
  type        = string
}

# Applies to clouds other than Kubernetes
variable "auth_types" {
  description = "List of supported authentication types by the cloud."
  type        = set(string)
  default     = null

  validation {
    condition     = (var.type != "kubernetes" && var.auth_types != null) || (var.type == "kubernetes" && var.auth_types == null)
    error_message = "auth_types must be set for this type of cloud"
  }
}

variable "ca_certificates" {
  description = "List of PEM-encoded X509 certificates for the cloud."
  type        = set(string)
  default     = null
}

variable "endpoint" {
  description = "Global endpoint for the cloud."
  type        = string
  default     = null
}

variable "identity_endpoint" {
  description = "Global identity endpoint for the cloud."
  type        = string
  default     = null
}

variable "storage_endpoint" {
  description = "Global storage endpoint for the cloud."
  type        = string
  default     = null
}

variable "regions" {
  description = "List of regions for the cloud. The first region in the list is the default region for the cloud."
  type = list(object({
    name              = string
    endpoint          = optional(string)
    identity_endpoint = optional(string)
    storage_endpoint  = optional(string)
  }))
  default = []
}

variable "target_controller" {
  description = "Only useful with JAAS - the backing controller where the cloud will be added. This field is required when running against a JAAS controller and must not be set otherwise. Changing this value will cause the cloud to be destroyed and recreated by terraform."
  type        = string
  default     = null
}

variable "credentials" {
  description = "Credential attributes accordingly to the cloud."
  type        = map(string)
  default     = null
  sensitive   = true

  validation {
    condition     = (var.type != "kubernetes" && var.credentials != null) || (var.type == "kubernetes" && var.credentials == null)
    error_message = "credentials must be set for this type of cloud"
  }
}

variable "add_credentials_to_client" {
  description = "Add credentials to the client."
  type        = bool
  default     = true
}

variable "add_credentials_to_controller" {
  description = "Add credentials to the controller."
  type        = bool
  default     = true
}

# Kubernetes specific
variable "kubernetes_config" {
  description = "The kubernetes config file path for the cloud. Cloud credentials will be added to the Juju controller for you."
  type        = string
  default     = null
  sensitive   = true
}
variable "parent_cloud_name" {
  description = "The parent cloud name, for adding a k8s cluster from an existing cloud. Changing this value will cause the cloud to be destroyed and recreated by terraform. Note that this value must be set when running against a JAAS controller."
  type        = string
  default     = null
}
variable "parent_cloud_region" {
  description = "The parent cloud region name, for adding a k8s cluster from an existing cloud. Changing this value will cause the cloud to be destroyed and recreated by terraform. Note that this value must be set when running against a JAAS controller."
  type        = string
  default     = null
}
variable "skip_service_account_creation" {
  description = "If set to true, the Juju Terraform provider will not create a service account and associated role within the K8s cluster and override the authentication info in the K8s config. This way it does not need to connect to the K8s API when adding a k8s cloud."
  type        = bool
  default     = true
}
variable "storage_class_name" {
  description = "Specify the Kubernetes storage class name for workload and operator storage."
  type        = string
  default     = null

  validation {
    condition     = (var.type == "kubernetes" && var.storage_class_name != null) || (var.type != "kubernetes" && var.storage_class_name == null)
    error_message = "storage_class_name must be set for a kubernetes cloud"
  }
}