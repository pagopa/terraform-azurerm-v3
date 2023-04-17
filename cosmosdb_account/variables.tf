# General Variables
variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "name" {
  type        = string
  description = "(Required) Specifies the name of the CosmosDB Account. Changing this forces a new resource to be created."
}

variable "domain" {
  type        = string
  description = "(Optional) Specifies the domain of the CosmosDB Account."
  default     = null
}

// Resource Group
variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which the CosmosDB Account is created. Changing this forces a new resource to be created."
}

variable "offer_type" {
  type        = string
  description = "The CosmosDB account offer type. At the moment can only be set to Standard"
  default     = "Standard"
}

variable "kind" {
  type        = string
  description = "Specifies the Kind of CosmosDB to create - possible values are GlobalDocumentDB and MongoDB."
}

// CosmosDB specific variables
variable "enable_free_tier" {
  type        = bool
  default     = true
  description = "Enable Free Tier pricing option for this Cosmos DB account. Defaults to false. Changing this forces a new resource to be created."
}

variable "enable_automatic_failover" {
  type        = bool
  default     = true
  description = "Enable automatic fail over for this Cosmos DB account."
}

variable "key_vault_key_id" {
  type        = string
  description = "(Optional) A versionless Key Vault Key ID for CMK encryption. Changing this forces a new resource to be created. When referencing an azurerm_key_vault_key resource, use versionless_id instead of id"
  default     = null
}

variable "mongo_server_version" {
  type        = string
  description = "The Server Version of a MongoDB account. Possible values are 4.0, 3.6, and 3.2."
  default     = null
}

variable "main_geo_location_location" {
  type        = string
  description = "(Required) The name of the Azure region to host replicated data."
}

variable "main_geo_location_zone_redundant" {
  type        = bool
  description = "Should zone redundancy be enabled for main region? Set true for prod environments"
}

variable "additional_geo_locations" {
  type = list(object({
    location          = string # The name of the Azure region to host replicated data.
    failover_priority = number # Required) The failover priority of the region. A failover priority of 0 indicates a write region. The maximum value for a failover priority = (total number of regions - 1). Failover priority values must be unique for each of the regions in which the database account exists. Changing this causes the location to be re-provisioned and cannot be changed for the location with failover priority 0.
    zone_redundant    = bool   # Should zone redundancy be enabled for this region? Defaults to false.
  }))
  default     = []
  description = "Specifies a list of additional geo_location resources, used to define where data should be replicated with the failover_priority 0 specifying the primary location."
}

variable "consistency_policy" {
  type = object({
    consistency_level       = string # The Consistency Level to use for this CosmosDB Account - can be either BoundedStaleness, Eventual, Session, Strong or ConsistentPrefix.
    max_interval_in_seconds = number # When used with the Bounded Staleness consistency level, this value represents the time amount of staleness (in seconds) tolerated. Accepted range for this value is 5 - 86400 (1 day). Defaults to 5. Required when consistency_level is set to BoundedStaleness.
    max_staleness_prefix    = number # When used with the Bounded Staleness consistency level, this value represents the number of stale requests tolerated. Accepted range for this value is 10 – 2147483647. Defaults to 100. Required when consistency_level is set to BoundedStaleness.
  })

  default = {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  description = "Specifies a consistency_policy resource, used to define the consistency policy for this CosmosDB account."
}

variable "capabilities" {
  type        = list(string)
  description = "The capabilities which should be enabled for this Cosmos DB account."
  default     = []
}

variable "subnet_id" {
  type        = string
  description = "Used only for private endpoints"
  default     = null
}

variable "private_dns_zone_ids" {
  type        = list(string)
  description = "Used only for private endpoints"
  default     = []
}

variable "private_endpoint_enabled" {
  type        = bool
  description = "Enable private endpoint"
  default     = true
}

variable "private_endpoint_name" {
  type        = string
  description = "Private endpoint name. If null it will assume the cosmosdb account name."
  default     = null
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether or not public network access is allowed for this CosmosDB account"
  default     = false
}

variable "is_virtual_network_filter_enabled" {
  type        = bool
  description = "Enables virtual network filtering for this Cosmos DB account."
  default     = true
}

variable "allowed_virtual_network_subnet_ids" {
  type        = list(string)
  description = "The subnets id that are allowed to access this CosmosDB account."
  default     = []
}

variable "enable_multiple_write_locations" {
  type        = bool
  description = "Enable multi-master support for this Cosmos DB account."
  default     = false
}

variable "ip_range" {
  type        = string
  description = "The set of IP addresses or IP address ranges in CIDR form to be included as the allowed list of client IP's for a given database account."
  default     = null
}

variable "backup_continuous_enabled" {
  type        = bool
  description = "Enable Continuous Backup"
  default     = true
}

variable "backup_periodic_enabled" {
  type = object({
    interval_in_minutes = string
    retention_in_hours  = string
    storage_redundancy  = string
  })
  description = "Enable Periodic Backup"
  default     = null
}

variable "lock_enable" {
  type        = bool
  default     = false
  description = "Apply lock to block accedentaly deletions."
}

variable "tags" {
  type = map(any)
}


# -------------------
# Alerts variables
# -------------------

variable "enable_provisioned_throughput_exceeded_alert" {
  type        = bool
  description = "Enable the Provisioned Throughput Exceeded alert. Default is true"
  default     = true
}

variable "provisioned_throughput_exceeded_threshold" {
  type        = number
  description = "The Provisioned Throughput Exceeded threshold. If metric average is over this value, the alert will be triggered. Default is 0, we want to act as soon as possible."
  default     = 0
}

variable "action" {
  description = "The ID of the Action Group and optional map of custom string properties to include with the post webhook operation."
  type = set(object(
    {
      action_group_id    = string
      webhook_properties = map(string)
    }
  ))
  default = []
}
