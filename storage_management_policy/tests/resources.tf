resource "azurerm_resource_group" "rg" {
  name     = "${local.project}-rg"
  location = var.location

  tags = var.tags
}

module "storage_account" {
  source = "../../storage_account"

  name                            = replace("${local.project}policysa", "-", "")
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  access_tier                     = "Hot"
  account_replication_type        = "GRS"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  advanced_threat_protection      = true
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true
  enable_low_availability_alert   = false

  blob_versioning_enabled  = true
  blob_change_feed_enabled = true

  tags = var.tags
}

module "storage_account_management_policy_example" {
  source = "../../storage_management_policy"

  storage_account_id = module.storage_account.id

  rules = [{
    name    = "${local.project}policysapolicy-blockBlob"
    enabled = true
    filters = {
      prefix_match = ["files-to-archive", "container2/prefix2"]
      blob_types   = ["blockBlob"]
    }
    actions = {
      base_blob = {
        tier_to_cool_after_days_since_modification_greater_than    = 0
        tier_to_archive_after_days_since_modification_greater_than = 1
        # delete_after_days_since_modification_greater_than          = 10
      }
      snapshot = {
        change_tier_to_archive_after_days_since_creation = 0
        change_tier_to_cool_after_days_since_creation    = 1
        delete_after_days_since_creation_greater_than    = 20
      }
      version = {
        change_tier_to_archive_after_days_since_creation = 0
        change_tier_to_cool_after_days_since_creation    = 1
        delete_after_days_since_creation                 = 30
      }
    }
    },
    # appendBlob only support delete policy
    {
      name    = "${local.project}policysapolicy-appendBlob"
      enabled = true
      filters = {
        prefix_match = ["insights-logs-auditevent"]
        blob_types   = ["appendBlob"]
      }
      actions = {
        base_blob = {
          delete_after_days_since_modification_greater_than = 1
        }
      }
  }]
}
