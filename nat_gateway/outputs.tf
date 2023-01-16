output "id" {
  value = azurerm_nat_gateway.this.id
}

output "resource_guid" {
  value = azurerm_nat_gateway.this.resource_guid
}

output "public_ip_address" {
  value = azurerm_public_ip.this.*.ip_address
}

output "public_ip_fqdn" {
  value = azurerm_public_ip.this.*.fqdn
}