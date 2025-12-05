# https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
data "azurecaf_name" "managed_redis" {
  name          = var.stack
  resource_type = "azurerm_redis_cache" # "azurerm_managed_redis"
  prefixes      = compact([local.name_prefix, "amr"])
  suffixes      = compact([var.client_name, var.location_short, var.environment, local.name_suffix])
  use_slug      = false
  clean_input   = true
  separator     = "-"
}
