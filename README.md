# Azure Managed Redis
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-blue.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![OpenTofu Registry](https://img.shields.io/badge/opentofu-registry-yellow.svg)](https://search.opentofu.org/module/claranet/managed-redis/azurerm/latest)

Azure module to deploy a [Azure Managed Redis](https://docs.microsoft.com/en-us/azure/xxxxxxx).

<!-- BEGIN_TF_DOCS -->
## Global versioning rule for Claranet Azure modules

| Module version | Terraform version | OpenTofu version | AzureRM version |
| -------------- | ----------------- | ---------------- | --------------- |
| >= 8.x.x       | **Unverified**    | 1.8.x            | >= 4.0          |
| >= 7.x.x       | 1.3.x             |                  | >= 3.0          |
| >= 6.x.x       | 1.x               |                  | >= 3.0          |
| >= 5.x.x       | 0.15.x            |                  | >= 2.0          |
| >= 4.x.x       | 0.13.x / 0.14.x   |                  | >= 2.0          |
| >= 3.x.x       | 0.12.x            |                  | >= 2.0          |
| >= 2.x.x       | 0.12.x            |                  | < 2.0           |
| <  2.x.x       | 0.11.x            |                  | < 2.0           |

## Contributing

If you want to contribute to this repository, feel free to use our [pre-commit](https://pre-commit.com/) git hook configuration
which will help you automatically update and format some files for you by enforcing our Terraform code module best-practices.

More details are available in the [CONTRIBUTING.md](./CONTRIBUTING.md#pull-request-process) file.

## Usage

This module is optimized to work with the [Claranet terraform-wrapper](https://github.com/claranet/terraform-wrapper) tool
which set some terraform variables in the environment needed by this module.
More details about variables set by the `terraform-wrapper` available in the [documentation](https://github.com/claranet/terraform-wrapper#environment).

⚠️ Since modules version v8.0.0, we do not maintain/check anymore the compatibility with
[Hashicorp Terraform](https://github.com/hashicorp/terraform/). Instead, we recommend to use [OpenTofu](https://github.com/opentofu/opentofu/).

```hcl
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

  default_database_options = {
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
  value        = module.managed_redis.resource.hostname
}

resource "azurerm_key_vault_secret" "redis_password" {
  key_vault_id = module.run.key_vault_id
  name         = "redis-password"
  value        = module.managed_redis.resource.default_database[0].primary_access_key
}

resource "azurerm_key_vault_secret" "redis_port" {
  key_vault_id = module.run.key_vault_id
  name         = "redis-port"
  value        = module.managed_redis.resource.default_database[0].port
}

resource "azurerm_key_vault_secret" "redis_connection_string" {
  key_vault_id = module.run.key_vault_id
  name         = "redis-connection-string"
  value        = format("redis://:%s@%s:%s", module.managed_redis.resource.default_database[0].primary_access_key, module.managed_redis.resource.hostname, module.managed_redis.resource.default_database[0].port)
}
```

## Providers

| Name | Version |
|------|---------|
| azurecaf | ~> 1.3.0 |
| azurerm | ~> 4.54 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| diagnostics | claranet/diagnostic-settings/azurerm | ~> 8.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_managed_redis.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis) | resource |
| [azurecaf_name.managed_redis](https://registry.terraform.io/providers/claranet/azurecaf/latest/docs/data-sources/name) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| client\_name | Client name/account used in naming. | `string` | n/a | yes |
| custom\_name | Custom Azure Managed Redis, generated if not set. | `string` | `""` | no |
| default\_database\_options | A Managed Redis instance will not be functional without a database. This block is intentionally optional to allow removal and re-creation of the database for troubleshooting purposes. | <pre>object({<br/>    access_keys_authentication_enabled = optional(bool)<br/>    client_protocol                    = optional(string, "Encrypted")<br/>    clustering_policy                  = optional(string, "OSSCluster")<br/>    eviction_policy                    = optional(string, "VolatileLRU")<br/>    # geo_replication_group_name =<br/><br/>    persistence_append_only_file_backup_frequency = optional(string) # AOF: The only possible value is '1s'<br/>    persistence_redis_database_backup_frequency   = optional(string) # RDB: Possible values are '1h', '6h', '12h'<br/><br/>    module = optional(object({<br/>      name = string<br/>      args = optional(list(string))<br/>    }))<br/>  })</pre> | `null` | no |
| default\_tags\_enabled | Option to enable or disable default tags. | `bool` | `true` | no |
| diagnostic\_settings\_custom\_name | Custom name of the diagnostics settings, name will be `default` if not set. | `string` | `"default"` | no |
| environment | Project environment. | `string` | n/a | yes |
| extra\_tags | Additional tags to add on resources. | `map(string)` | `{}` | no |
| high\_availability\_enabled | Whether to enable high availability for the Redis Cluster. | `bool` | `true` | no |
| identity | Identity block information. | <pre>object({<br/>    type         = optional(string, "SystemAssigned")<br/>    identity_ids = optional(list(string))<br/>  })</pre> | `{}` | no |
| location | Azure region to use. | `string` | n/a | yes |
| location\_short | Short string for Azure location. | `string` | n/a | yes |
| logs\_categories | Log categories to send to destinations. | `list(string)` | `null` | no |
| logs\_destinations\_ids | List of destination resources IDs for logs diagnostic destination.<br/>Can be `Storage Account`, `Log Analytics Workspace` and `Event Hub`. No more than one of each can be set.<br/>If you want to use Azure EventHub as a destination, you must provide a formatted string containing both the EventHub Namespace authorization send ID and the EventHub name (name of the queue to use in the Namespace) separated by the <code>&#124;</code> character. | `list(string)` | n/a | yes |
| logs\_metrics\_categories | Metrics categories to send to destinations. | `list(string)` | `null` | no |
| name\_prefix | Optional prefix for the generated name. | `string` | `""` | no |
| name\_suffix | Optional suffix for the generated name. | `string` | `""` | no |
| public\_network\_access\_enabled | Whether the Azure Managed Redis is available from public network. | `bool` | `false` | no |
| resource\_group\_name | Name of the resource group. | `string` | n/a | yes |
| sku\_name | Redis Cluster SKU name. | `string` | n/a | yes |
| stack | Project stack name. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| id | Azure Managed Redis ID. |
| identity\_principal\_id | Azure Managed Redis system identity principal ID. |
| module\_diagnostics | Diagnostics settings module outputs. |
| name | Azure Managed Redis name. |
| resource | Azure Managed Redis resource object. |
<!-- END_TF_DOCS -->

## Related documentation

Microsoft Azure documentation: xxxx
