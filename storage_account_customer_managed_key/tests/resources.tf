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
  public_network_access_enabled   = true

  blob_versioning_enabled              = true
  blob_container_delete_retention_days = 7
  blob_delete_retention_days           = 7
  blob_change_feed_enabled             = true
  blob_change_feed_retention_in_days   = 10
  blob_storage_policy = {
    blob_restore_policy_days   = 6
    enable_immutability_policy = false
  }

  enable_identity = true

  tags = var.tags
}

module "key_vault" {
  source = "../../key_vault"

  name                       = "${local.project}-kv"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 90

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = module.key_vault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions         = ["Get", "List", "Update", "Create", "Import", "Delete", ]
  secret_permissions      = ["Get", "List", "Set", "Delete", "Restore", "Recover", ]
  storage_permissions     = []
  certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Restore", "Recover", ]
}

module "storage_account_customer_managed_key" {
  source = "../../storage_account_customer_managed_key"

  tenant_id            = data.azurerm_subscription.current.tenant_id
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  key_vault_id         = module.key_vault.id
  key_name             = "${local.project}-key"
  storage_id           = module.storage_account.id
  storage_principal_id = module.storage_account.identity.0.principal_id

  # depends_on = [azurerm_key_vault_access_policy.current_user]
}
