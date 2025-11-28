resource "azurerm_managed_redis" "main" {
  name = local.name

  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "identity" {
    for_each = var.identity[*]
    content {
      type         = var.identity.type
      identity_ids = endswith(var.identity.type, "UserAssigned") ? var.identity.identity_ids : null
    }
  }

  tags = merge(local.default_tags, var.extra_tags)
}
