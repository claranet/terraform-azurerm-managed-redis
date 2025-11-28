output "resource" {
  description = "Azure Managed Redis resource object."
  value       = azurerm_managed_redis.main
}

output "id" {
  description = "Azure Managed Redis ID."
  value       = azurerm_managed_redis.main.id
}

output "name" {
  description = "Azure Managed Redis name."
  value       = azurerm_managed_redis.main.name
}

output "identity_principal_id" {
  description = "Azure Managed Redis system identity principal ID."
  value       = try(azurerm_managed_redis.main.identity[0].principal_id, null)
}

output "module_diagnostics" {
  description = "Diagnostics settings module outputs."
  value       = module.diagnostics
}
