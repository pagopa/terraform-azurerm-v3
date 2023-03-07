resource "azurerm_resource_group" "rg" {
  name     = "${local.project}-rg"
  location = var.location

  tags = var.tags
}

module "storage_account" {
  source = "../../storage_account"

  name                            = replace("${local.project}st", "-", "")
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  access_tier                     = "Hot"
  account_replication_type        = "GRS"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  advanced_threat_protection      = true
  allow_nested_items_to_be_public = false

  blob_versioning_enabled              = true
  blob_container_delete_retention_days = 7
  blob_delete_retention_days           = 7
  blob_change_feed_enabled             = true
  blob_change_feed_retention_in_days   = 10
  blob_restore_policy_days             = 6

  tags = var.tags
}
