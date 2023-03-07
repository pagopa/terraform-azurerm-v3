resource "azurerm_resource_group" "rg" {
  name     = "${local.project}-rg"
  location = var.location
  tags     = var.tags
}

module "storage_api" {
  source = "../../storage_account"

  name                            = replace("${local.project}st", "-", "")
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  access_tier                     = "Hot"
  blob_versioning_enabled         = true
  account_replication_type        = "GRS"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  advanced_threat_protection      = true
  allow_nested_items_to_be_public = false

  blob_delete_retention_days      = 7
  container_delete_retention_days = 7

  tags = var.tags
}
