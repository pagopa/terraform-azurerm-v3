variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "domain" {
  type        = string
  description = "(Optional) Specifies the domain of the Storage Account."
  default     = null
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

variable "blob_delete_retention_days" {
  description = "Retention days for deleted blob. Valid value is between 1 and 365 (set to 0 to disable)."
  type        = number
  default     = 0
}

variable "blob_container_delete_retention_days" {
  description = "Retention days for deleted container. Valid value is between 1 and 365 (set to 0 to disable)."
  type        = number
  default     = 0
}

variable "min_tls_version" {
  type        = string
  default     = "TLS1_2"
  description = "The minimum supported TLS version for the storage account. Possible values are TLS1_0, TLS1_1, and TLS1_2"
}

variable "is_hns_enabled" {
  type        = bool
  default     = false
  description = "Enable Hierarchical Namespace enabled (Azure Data Lake Storage Gen 2). Changing this forces a new resource to be created."
}

variable "allow_nested_items_to_be_public" {
  description = "Allow or disallow public access to all blobs or containers in the storage account."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Enable or Disable public access. It should always set to false unless there are special needs"
  type        = bool
}

variable "blob_versioning_enabled" {
  description = "Controls whether blob object versioning is enabled."
  type        = bool
  default     = false
}

variable "blob_change_feed_enabled" {
  description = "(Optional) Is the blob service properties for change feed events enabled? Default to false."
  type        = bool
  default     = false
}

variable "blob_change_feed_retention_in_days" {
  description = "(Optional) The duration of change feed events retention in days. The possible values are between 1 and 146000 days (400 years). Setting this to null (or omit this in the configuration file) indicates an infinite retention of the change feed."
  type        = number
  default     = null
}

variable "blob_restore_policy_days" {
  description = "(Optional) Specifies the number of days that the blob can be restored, between 1 and 365 days. This must be less than the days specified for delete_retention_policy."
  type        = number
  default     = 0
}

variable "cross_tenant_replication_enabled" {
  description = "(Optional) Should cross Tenant replication be enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "enable_identity" {
  description = "(Optional) If true, set the identity as SystemAssigned"
  type        = bool
  default     = false
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

variable "custom_domain" {
  type = object({
    name          = string
    use_subdomain = bool
  })
  description = "Custom domain for accessing blob data"
  default = {
    name          = null
    use_subdomain = false
  }
}


# -------------------
# Alerts variables
# -------------------

variable "enable_low_availability_alert" {
  type        = bool
  description = "Enable the Low Availability alert. Default is true"
  default     = true
}

variable "low_availability_threshold" {
  type        = number
  description = "The Low Availability threshold. If metric average is under this value, the alert will be triggered. Default is 99.8"
  default     = 99.8
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
