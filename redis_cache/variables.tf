variable "location" {
  type        = string
  description = "The location of the resource group."
}

variable "name" {
  type        = string
  description = "The name of the Redis instance."
}

variable "resource_group_name" {
  type = string
}

variable "capacity" {
  type        = number
  description = "The size of the Redis cache to deploy"
  default     = 1
}

variable "shard_count" {
  type        = number
  description = "The number of Shards to create on the Redis Cluster."
  default     = null
}

variable "enable_non_ssl_port" {
  type        = bool
  description = "Enable the non-SSL port (6379) - disabled by default."
  default     = false
}

variable "subnet_id" {
  type        = string
  description = "The Subnet within which the Redis Cache should be deployed (Deprecated, use private_endpoint)"
  default     = null
}

variable "private_endpoint" {
  type = object({
    enabled              = bool
    virtual_network_id   = string
    subnet_id            = string
    private_dns_zone_ids = list(string)
  })
  description = "(Required) Enable private endpoint with required params"
}

variable "private_static_ip_address" {
  type        = string
  description = "The Static IP Address to assign to the Redis Cache when hosted inside the Virtual Network"
  default     = null
}

variable "public_network_access_enabled" {
  type        = string
  description = "Whether or not public network access is allowed for this Redis Cache. true means this resource could be accessed by both public and private endpoint. false means only private endpoint access is allowed. Defaults to false."
  default     = false
}

variable "family" {
  type        = string
  description = "The SKU family/pricing group to use"
}

variable "sku_name" {
  type        = string
  description = "The SKU of Redis to use"
}

variable "redis_version" {
  type        = string
  description = "The version of Redis to use: 4 (deprecated) or 6"
}

# Redis configuration #


# NOTE: enable_authentication can only be set to false if a subnet_id is specified; and only works
# if there aren't existing instances within the subnet with enable_authentication set to true.
variable "enable_authentication" {
  type        = bool
  description = "If set to false, the Redis instance will be accessible without authentication. Defaults to true."
  default     = true
}

variable "backup_configuration" {
  type = object({
    frequency                 = number
    max_snapshot_count        = number
    storage_connection_string = string
  })
  default = null
}

variable "patch_schedules" {
  type = list(object({
    day_of_week    = string
    start_hour_utc = number
  }))
  default = []
}

variable "tags" {
  type = map(any)
}
