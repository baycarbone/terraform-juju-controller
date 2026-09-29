output "name" {
  description = "The name of the Juju model."
  value       = juju_model.model.name
}

output "uuid" {
  description = "The UUID of the Juju model."
  value       = juju_model.model.uuid
}

output "cloud" {
  description = "The name of the cloud the model is deployed to."
  value       = var.cloud_name
}
