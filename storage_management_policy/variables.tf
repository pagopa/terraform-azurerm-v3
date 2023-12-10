variable "storage_account_id" {
  type        = string
  description = "Specifies the id of the storage account to apply the management policy to."
}

variable "rules" {
  type = list(object({
    name    = string
    enabled = bool
    filters = object({
      prefix_match = list(string) # (Optional) An array of strings for prefixes to be matched.
      blob_types   = list(string) # (Required) An array of predefined values. Valid options are blockBlob and appendBlob.
    })
    actions = object({
      base_blob = object({
        delete_after_days_since_modification_greater_than              = number
        delete_after_days_since_creation_greater_than                  = optional(number, -1)
        delete_after_days_since_last_access_time_greater_than          = optional(number, -1)
        tier_to_cool_after_days_since_modification_greater_than        = number
        tier_to_cool_after_days_since_creation_greater_than            = optional(number, -1)
        tier_to_cool_after_days_since_last_access_time_greater_than    = optional(number, -1)
        tier_to_archive_after_days_since_modification_greater_than     = number
        tier_to_archive_after_days_since_creation_greater_than         = optional(number, -1)
        tier_to_archive_after_days_since_last_access_time_greater_than = optional(number, -1)
        tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number, -1)
      })
      snapshot = optional(object({
        change_tier_to_archive_after_days_since_creation               = number
        change_tier_to_cool_after_days_since_creation                  = number
        delete_after_days_since_creation_greater_than                  = optional(number, -1)
        tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number, -1)
      }), null)
      version = optional(object({
        change_tier_to_archive_after_days_since_creation               = number
        change_tier_to_cool_after_days_since_creation                  = number
        delete_after_days_since_creation                               = optional(number, -1)
        tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number, -1)
      }), null)
    })
  }))
  default = []
}
