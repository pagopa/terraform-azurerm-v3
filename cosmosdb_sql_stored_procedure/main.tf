resource "azurerm_cosmosdb_sql_stored_procedure" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  account_name        = var.account_name
  database_name       = var.database_name
  container_name      = var.container_name
  body = var.body
}
