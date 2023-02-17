resource "azurerm_key_vault_access_policy" "storage" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = var.storage_principal_id

  key_permissions    = ["Get", "Create", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

# tfsec:ignore:azure-keyvault-ensure-key-expiry
resource "azurerm_key_vault_key" "key" {
  name         = var.key_name
  key_vault_id = var.key_vault_id
  key_type     = "RSA"
  key_size     = var.key_size
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [
    azurerm_key_vault_access_policy.storage,
  ]
}

resource "azurerm_storage_account_customer_managed_key" "this" {
  storage_account_id = var.storage_id
  key_vault_id       = var.key_vault_id
  key_name           = azurerm_key_vault_key.key.name
}