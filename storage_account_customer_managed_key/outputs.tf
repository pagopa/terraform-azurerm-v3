output "id" {
  value = azurerm_storage_account_customer_managed_key.this.id
}

output "key_id" {
  value = azurerm_key_vault_key.key.id
}