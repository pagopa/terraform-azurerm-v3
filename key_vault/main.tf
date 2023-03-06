
resource "azurerm_key_vault" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = var.sku_name

  enabled_for_disk_encryption   = true
  enable_rbac_authorization     = var.enable_rbac_authorization
  soft_delete_retention_days    = var.soft_delete_retention_days
  purge_protection_enabled      = true
  public_network_access_enabled = var.public_network_access_enabled

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow" #tfsec:ignore:AZU020
  }

  tags = var.tags
}

# terraform cloud policy
resource "azurerm_key_vault_access_policy" "terraform_cloud_policy" {
  count        = var.terraform_cloud_object_id != null ? 1 : 0
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.tenant_id
  object_id    = var.terraform_cloud_object_id

  key_permissions = ["Get", "List", "Update", "Create", "Import", "Delete",
    "Recover", "Backup", "Restore"
  ]

  secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Backup",
    "Restore"
  ]

  certificate_permissions = ["Get", "List", "Update", "Create", "Import",
    "Delete", "Recover", "Backup", "Restore", "ManageContacts", "ManageIssuers",
    "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers", "Purge"
  ]

  storage_permissions = []

}

resource "azurerm_management_lock" "this" {
  count      = var.lock_enable ? 1 : 0
  name       = format("%s-lock", azurerm_key_vault.this.name)
  scope      = azurerm_key_vault.this.id
  lock_level = "CanNotDelete"
  notes      = "this items can't be deleted in this subscription!"
}

resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  count                      = var.sec_log_analytics_workspace_id != null ? 1 : 0
  name                       = "SecurityLogs"
  target_resource_id         = azurerm_key_vault.this.id
  log_analytics_workspace_id = var.sec_log_analytics_workspace_id
  storage_account_id         = var.sec_storage_id

  log {
    category = "AuditEvent"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "AzurePolicyEvaluationDetails"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 365
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false
    retention_policy {
      enabled = false
    }
  }
}
