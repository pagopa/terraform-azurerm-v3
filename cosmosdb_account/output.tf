output "id" {
  description = "The id of the CosmosDB account."
  value       = azurerm_cosmosdb_account.this.id
}

output "name" {
  description = "The name of the CosmosDB created."
  value       = azurerm_cosmosdb_account.this.name
}

output "endpoint" {
  description = "The endpoint used to connect to the CosmosDB account."
  value       = azurerm_cosmosdb_account.this.endpoint
}

output "write_endpoints" {
  description = "A list of write endpoints available for this CosmosDB account."
  value       = azurerm_cosmosdb_account.this.write_endpoints
}

output "read_endpoints" {
  description = "A list of read endpoints available for this CosmosDB account."
  value       = azurerm_cosmosdb_account.this.read_endpoints
}

# @deprecated
output "primary_master_key" {
  value     = azurerm_cosmosdb_account.this.primary_key
  sensitive = true
}

output "primary_key" {
  value     = azurerm_cosmosdb_account.this.primary_key
  sensitive = true
}

output "secondary_key" {
  value     = azurerm_cosmosdb_account.this.secondary_key
  sensitive = true
}

# @deprecated
output "primary_readonly_master_key" {
  value     = azurerm_cosmosdb_account.this.primary_readonly_key
  sensitive = true
}

output "primary_readonly_key" {
  value     = azurerm_cosmosdb_account.this.primary_readonly_key
  sensitive = true
}

output "connection_strings" {
  value     = azurerm_cosmosdb_account.this.connection_strings
  sensitive = true
}

output "principal_id" {
  value = azurerm_cosmosdb_account.this.identity.0.principal_id
}
