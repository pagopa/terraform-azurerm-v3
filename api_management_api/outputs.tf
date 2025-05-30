output "id" {
  value = azurerm_api_management_api.this.id
}

output "name" {
  value = azurerm_api_management_api.this.name
}


output "soap_operation_ids" {
  value = data.external.soap_action.*.result
}
