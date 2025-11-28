variable "identity" {
  description = "Identity block information."
  type = object({
    type         = optional(string, "SystemAssigned")
    identity_ids = optional(list(string))
  })
  default  = {}
  nullable = false
}

variable "sku_name" {
  description = "Redis Cluster SKU name."
  type        = string
  nullable    = false
}

variable "high_availability_enabled" {
  description = "Whether to enable high availability for the Redis Cluster."
  type        = bool
  default     = true
  nullable    = false
}

variable "default_database_options" {
  description = "A Managed Redis instance will not be functional without a database. This block is intentionally optional to allow removal and re-creation of the database for troubleshooting purposes."
  type = object({
    access_keys_authentication_enabled = optional(bool)
    client_protocol                    = optional(string, "Encrypted")
    clustering_policy                  = optional(string, "OSSCluster")
    eviction_policy                    = optional(string, "VolatileLRU")
    # geo_replication_group_name =

    persistence_append_only_file_backup_frequency = optional(string) # AOF: The only possible value is '1s'
    persistence_redis_database_backup_frequency   = optional(string) # RDB: Possible values are '1h', '6h', '12h'

    module = optional(object({
      name = string
      args = optional(list(string))
    }))
  })
  default = null
}
