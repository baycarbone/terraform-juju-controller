output "name" {
  description = "The name of the Juju model."
  value       = juju_model.model.name
}

output "uuid" {
  description = "The UUID of the Juju model."
  value       = juju_model.model.uuid
}
