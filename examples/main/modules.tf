module "managed_redis" {
  source  = "claranet/managed-redis/azurerm"
  version = "x.x.x"

  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  resource_group_name = module.rg.name

  client_name = var.client_name
  environment = var.environment
  stack       = var.stack

  sku_name = "Balanced_B10"

  high_availability_enabled = true

  default_database_config = {
    access_keys_authentication_enabled = true
    clustering_policy                  = "OSSCluster"
    eviction_policy                    = "VolatileLRU"

    # persistence_append_only_file_backup_frequency = "1s" # AOF Backup
    persistence_redis_database_backup_frequency = "1h" # RDB Backup
  }

  logs_destinations_ids = [
    module.run.logs_storage_account_id,
    module.run.log_analytics_workspace_id,
  ]

  extra_tags = {
    foo = "bar"
  }
}

resource "azurerm_key_vault_secret" "redis_hostname" {
  key_vault_id = module.run.key_vault_id
  name         = "redis-hostname"
  value        = module.managed_redis.hostname
}

resource "azurerm_key_vault_secret" "redis_password" {
  key_vault_id = module.run.key_vault_id
  name         = "redis-password"
  value        = module.managed_redis.primary_access_key
}

resource "azurerm_key_vault_secret" "redis_port" {
  key_vault_id = module.run.key_vault_id
  name         = "redis-port"
  value        = module.managed_redis.port
}

resource "azurerm_key_vault_secret" "redis_connection_string" {
  key_vault_id = module.run.key_vault_id
  name         = "redis-connection-string"
  value        = format("redis://:%s@%s:%s", azurerm_key_vault_secret.redis_password.value, module.managed_redis.hostname, module.managed_redis.port)
}
