variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "account_kind" {
  type        = string
  default     = "StorageV2"
  description = "(Optional) Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Changing this forces a new resource to be created."
}

variable "account_tier" {
  type        = string
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created."
}

variable "access_tier" {
  type        = string
  default     = null
  description = "(Optional) Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot"
}

variable "account_replication_type" {
  type        = string
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. Changing this forces a new resource to be created when types LRS, GRS and RAGRS are changed to ZRS, GZRS or RAGZRS and vice versa"
}

variable "blob_properties_delete_retention_policy_days" {
  type        = number
  default     = null
  description = "Enable soft delete policy and specify the number of days that the blob should be retained. Between 1 and 365 days"
}

variable "min_tls_version" {
  type        = string
  default     = "TLS1_2"
  description = "The minimum supported TLS version for the storage account. Possible values are TLS1_0, TLS1_1, and TLS1_2"
}

variable "enable_https_traffic_only" {
  type        = bool
  default     = true
  description = "Boolean flag which forces HTTPS if enabled, see here for more information. Defaults to true"
}

variable "is_hns_enabled" {
  type        = bool
  default     = false
  description = "Enable Hierarchical Namespace enabled (Azure Data Lake Storage Gen 2). Changing this forces a new resource to be created."
}

variable "allow_blob_public_access" {
  type        = bool
  default     = false
  description = "Allow or disallow public access to all blobs or containers in the storage account."
}

# Note: If specifying network_rules,
# one of either ip_rules or virtual_network_subnet_ids must be specified
# and default_action must be set to Deny.

variable "network_rules" {
  type = object({
    default_action             = string       # Specifies the default action of allow or deny when no other rules match. Valid options are Deny or Allow
    bypass                     = set(string)  # Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of Logging, Metrics, AzureServices, or None
    ip_rules                   = list(string) # List of public IP or IP ranges in CIDR Format. Only IPV4 addresses are allowed
    virtual_network_subnet_ids = list(string) # A list of resource ids for subnets.
  })
  default = null
}

variable "enable_versioning" {
  type        = bool
  default     = false
  description = "Enable versioning in the blob storage account."
}

# versioning

variable "versioning_name" {
  type    = string
  default = null
}

# lock

variable "lock_enabled" {
  type        = bool
  default     = false
  description = "Is lock enabled?"
}

variable "lock_name" {
  type        = string
  default     = null
  description = "Specifies the name of the Management Lock. Changing this forces a new resource to be created."
}

variable "lock_level" {
  type        = string
  default     = null
  description = " Specifies the Level to be used for this Lock. Possible values are CanNotDelete and ReadOnly."
}

variable "lock_notes" {
  type        = string
  default     = null
  description = "Specifies some notes about the lock. Maximum of 512 characters."
}

variable "advanced_threat_protection" {
  type        = string
  default     = false
  description = "Should Advanced Threat Protection be enabled on this resource?"
}

variable "tags" {
  type = map(any)
}

variable "index_document" {
  type        = string
  default     = null
  description = "The webpage that Azure Storage serves for requests to the root of a website or any subfolder. For example, index.html. The value is case-sensitive."
}

variable "error_404_document" {
  type        = string
  default     = null
  description = "The absolute path to a custom webpage that should be used when a request is made which does not correspond to an existing file."
}
