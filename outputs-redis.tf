output "primary_access_key" {
  description = "The primary access key of the Redis Cluster default database."
  value       = one(azurerm_managed_redis.main.default_database[*].primary_access_key)
  sensitive   = true
}

output "hostname" {
  description = "The hostname of the Redis Cluster."
  value       = azurerm_managed_redis.main.hostname
}

output "port" {
  description = "The port of the Redis Cluster default database."
  value       = one(azurerm_managed_redis.main.default_database[*].port)
}

output "terraform_module" {
  description = "Information about this Terraform module."
  value = {
    name       = "redis"
    provider   = "azurerm"
    maintainer = "claranet"
  }
}
