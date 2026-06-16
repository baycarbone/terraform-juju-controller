name = "test-tofu"
cloud = {
  auth_types = ["certificate"]
  name       = "lxd-cloud"
  type       = "lxd"
  endpoint   = "https://192.168.1.66:8443"
  region = {
    name     = "default"
    endpoint = "https://192.168.1.66:8443"
  }
}
cloud_credential = {
  auth_type = "interactive"
  name      = "lxd-token"
  attributes = {
    trust-token = "eyJjbGllbnRfbmFtZSI6InRlc3QiLCJmaW5nZXJwcmludCI6IjViODNkOTM1YTg0Yzg2ZDhlZGRhZDNiYWE3MDA2YTJjMjRlOWFmMzBmYWIzNzNkYWJjNWUzYTlkNDVmODM0NWEiLCJhZGRyZXNzZXMiOlsiMTkyLjE2OC4xLjY2Ojg0NDMiLCIxMC4xNjMuMTM5LjE6ODQ0MyIsIltmZDQyOmY1ZToyYzVlOjZmNTg6OjFdOjg0NDMiXSwic2VjcmV0IjoiMTZlYjQ3MTJiMTg3ZTliNGYyNzJkODk1NDNmZmY0NmY4YzE1MTE4YWViMDQ4YjU4M2E1MGY5M2ViMDQ3NjJjOCIsImV4cGlyZXNfYXQiOiIyMDI2LTA2LTA1VDE0OjQxOjA3LjY5MjYzNjczMSswMjowMCIsInR5cGUiOiIifQ=="
  }
}
controller_num_units = 3
