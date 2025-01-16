variable "name" {
  type        = string
  description = "The name of the Cosmos DB instance."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the Cosmos DB SQL"
}

variable "account_name" {
  type        = string
  description = "The name of the Cosmos DB Account to create the container within."
}

variable "database_name" {
  type        = string
  description = "The name of the Cosmos DB SQL Database to create the container within."
}

variable "partition_key_path" {
  type        = string
  description = "Define a partition key."
  default     = null
}

variable "throughput" {
  type        = number
  description = "The throughput of SQL container (RU/s). Must be set in increments of 100. The minimum value is 400."
  default     = null
}

variable "default_ttl" {
  type        = number
  description = "The default time to live of SQL container. If missing, items are not expired automatically."
  default     = null
}

variable "unique_key_paths" {
  type        = list(string)
  description = "A list of paths to use for this unique key."
  default     = []
}

variable "autoscale_settings" {
  type = object({
    max_throughput = number
  })
  default     = null
  description = "Autoscale settings for collection"
}

variable "indexing_policy" {
  type = object({
    # The indexing strategy. Valid options are: consistent, none
    indexing_mode = optional(string, "consistent"),

    # One or more paths for which the indexing behaviour applies to. Either included_path or excluded_path must contain the path '/*'
    included_paths = optional(list(string), ["/*"]),

    # One or more paths that are excluded from indexing. Either included_path or excluded_path must contain the path '/*'
    excluded_paths = optional(list(string), []),

    # One or more path that define complex indexes. There can be multiple composite indexes on same indexing policy
    composite_indexes = optional(list(list(object(
      {
        # The path of the field to be included in the composite index
        path = string

        # The sort of single field in indexing structure. Valid options are: ascending, descending
        order = optional(string, "ascending")
      }
    ))), []),
  })
  default     = null
  description = "The configuration of indexes on collection"
}
