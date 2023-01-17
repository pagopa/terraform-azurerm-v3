# General Variables
variable "name" {
  type        = string
  description = "Specifies the name of the Cosmos DB Mongo Collection. Changing this forces a new resource to be created."
}

variable "lock_enable" {
  type        = bool
  default     = false
  description = "Apply lock to block accidental deletions."
}

// Resource Group
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the Cosmos DB Mongo Collection is created. Changing this forces a new resource to be created."
}

// CosmosDB Mongodb Collection specific variables
variable "cosmosdb_mongo_account_name" {
  type        = string
  description = "The name of the Cosmos DB Mongo Account in which the Cosmos DB Mongo Database exists. Changing this forces a new resource to be created."
}

variable "cosmosdb_mongo_database_name" {
  type        = string
  description = "The name of the Cosmos DB Mongo Database in which the Cosmos DB Mongo Collection is created. Changing this forces a new resource to be created."
}

variable "default_ttl_seconds" {
  type        = number
  default     = null #https://github.com/hashicorp/terraform-provider-azurerm/pull/16405
  description = "The default Time To Live in seconds. If the value is -1 or 0, items are not automatically expired."
}

variable "analytical_storage_ttl" {
  type        = number
  default     = null
  description = "The default time to live of Analytical Storage for this Mongo Collection. If present and the value is set to -1, it is equal to infinity, and items don’t expire by default. If present and the value is set to some number n – items will expire n seconds after their last modified time."
}

variable "shard_key" {
  type        = string
  default     = null
  description = "The name of the key to partition on for sharding. There must not be any other unique index keys."
}

variable "indexes" {
  type = list(object({
    keys   = list(string)
    unique = bool
  }))
  description = "One or more indexes. An index with an \"_id\" key must be specified."
}

variable "throughput" {
  type        = number
  default     = null
  description = "The throughput of the MongoDB collection (RU/s). Must be set in increments of 100. The minimum value is 400. This must be set upon database creation otherwise it cannot be updated without a manual terraform destroy-apply."
}

variable "max_throughput" {
  type        = number
  default     = null
  description = "It will activate the autoscale mode setting the maximum throughput of the MongoDB collection (RU/s). Must be between 4,000 and 1,000,000. Must be set in increments of 1,000. Conflicts with throughput. Switching between autoscale and manual throughput is not supported via Terraform and must be completed via the Azure Portal and refreshed."
}

variable "timeout_create" {
  type        = string
  default     = null
  description = "(Defaults to 30 minutes) Used when creating the CosmosDB Mongo Collection."
}

variable "timeout_update" {
  type        = string
  default     = null
  description = "(Defaults to 30 minutes) Used when updating the CosmosDB Mongo Collection."
}

variable "timeout_read" {
  type        = string
  default     = null
  description = "(Defaults to 5 minutes) Used when retrieving the CosmosDB Mongo Collection."
}

variable "timeout_delete" {
  type        = string
  default     = null
  description = "(Defaults to 30 minutes) Used when deleting the CosmosDB Mongo Collection."
}
