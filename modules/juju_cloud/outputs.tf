output "name" {
  description = "The name of the cloud in Juju."
  value       = try(juju_cloud.cloud[0].name, juju_kubernetes_cloud.cloud[0].name)
}

output "region" {
  description = "The name of the default region in the cloud."
  value       = try(juju_cloud.cloud[0].regions[0], null)
}
