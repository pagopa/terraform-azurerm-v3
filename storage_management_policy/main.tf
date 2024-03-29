#
# ⚠️ Attention: Archive policies are only available for this type of storage: LRS, GRS, or RA-GRS
# see: https://learn.microsoft.com/en-us/azure/storage/blobs/access-tiers-overview
#
resource "azurerm_storage_management_policy" "this" {
  storage_account_id = var.storage_account_id

  dynamic "rule" {
    for_each = toset(var.rules)
    content {
      name    = rule.value.name
      enabled = rule.value.enabled

      dynamic "filters" {
        for_each = rule.value.filters == null ? [] : tolist([rule.value.filters])
        content {
          prefix_match = filters.value.prefix_match
          blob_types   = filters.value.blob_types
        }
      }

      actions {
        base_blob {
          delete_after_days_since_modification_greater_than              = rule.value.actions.base_blob.delete_after_days_since_modification_greater_than
          delete_after_days_since_creation_greater_than                  = rule.value.actions.base_blob.delete_after_days_since_creation_greater_than
          delete_after_days_since_last_access_time_greater_than          = rule.value.actions.base_blob.delete_after_days_since_last_access_time_greater_than
          tier_to_cool_after_days_since_modification_greater_than        = rule.value.actions.base_blob.tier_to_cool_after_days_since_modification_greater_than
          tier_to_cool_after_days_since_creation_greater_than            = rule.value.actions.base_blob.tier_to_cool_after_days_since_creation_greater_than
          tier_to_cool_after_days_since_last_access_time_greater_than    = rule.value.actions.base_blob.tier_to_cool_after_days_since_last_access_time_greater_than
          tier_to_archive_after_days_since_modification_greater_than     = rule.value.actions.base_blob.tier_to_archive_after_days_since_modification_greater_than
          tier_to_archive_after_days_since_creation_greater_than         = rule.value.actions.base_blob.tier_to_archive_after_days_since_creation_greater_than
          tier_to_archive_after_days_since_last_access_time_greater_than = rule.value.actions.base_blob.tier_to_archive_after_days_since_last_access_time_greater_than
          tier_to_archive_after_days_since_last_tier_change_greater_than = rule.value.actions.base_blob.tier_to_archive_after_days_since_last_tier_change_greater_than
        }
        dynamic "snapshot" {
          for_each = rule.value.actions.snapshot == null ? [] : tolist([rule.value.actions.snapshot])
          content {
            change_tier_to_archive_after_days_since_creation = snapshot.value.change_tier_to_archive_after_days_since_creation
            change_tier_to_cool_after_days_since_creation    = snapshot.value.change_tier_to_cool_after_days_since_creation
            delete_after_days_since_creation_greater_than    = snapshot.value.delete_after_days_since_creation_greater_than
          }
        }
        dynamic "version" {
          for_each = rule.value.actions.version == null ? [] : tolist([rule.value.actions.version])
          content {
            change_tier_to_archive_after_days_since_creation = version.value.change_tier_to_archive_after_days_since_creation
            change_tier_to_cool_after_days_since_creation    = version.value.change_tier_to_cool_after_days_since_creation
            delete_after_days_since_creation                 = version.value.delete_after_days_since_creation
          }
        }
      }
    }
  }
}
