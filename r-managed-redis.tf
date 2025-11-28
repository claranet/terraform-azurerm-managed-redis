resource "azurerm_managed_redis" "main" {
  name = local.name

  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = var.sku_name

  public_network_access     = var.public_network_access_enabled ? "Enabled" : "Disabled"
  high_availability_enabled = var.high_availability_enabled

  dynamic "default_database" {
    for_each = var.default_database_options[*]
    iterator = db
    content {
      access_keys_authentication_enabled = db.value.access_keys_authentication_enabled
      client_protocol                    = db.value.client_protocol
      clustering_policy                  = db.value.clustering_policy
      eviction_policy                    = db.value.eviction_policy

      persistence_append_only_file_backup_frequency = db.value.persistence_append_only_file_backup_frequency
      persistence_redis_database_backup_frequency   = db.value.persistence_redis_database_backup_frequency

      dynamic "module" {
        for_each = db.value.module[*]
        content {
          name = module.value.name
          args = module.value.args
        }
      }
    }
  }

  dynamic "identity" {
    for_each = var.identity[*]
    content {
      type         = var.identity.type
      identity_ids = endswith(var.identity.type, "UserAssigned") ? var.identity.identity_ids : null
    }
  }

  tags = merge(local.default_tags, var.extra_tags)
}
