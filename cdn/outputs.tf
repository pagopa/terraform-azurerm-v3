output "id" {
  value = azurerm_cdn_endpoint.this.id
}

locals {
  hostname = join(".", [azurerm_cdn_endpoint.this.name, "azureedge.net"])
}

output "hostname" {
  value = local.hostname
}

output "fqdn" {
  value = var.dns_zone_name != var.hostname ? trimsuffix(azurerm_dns_cname_record.custom_subdomain[0].fqdn, ".") : trimsuffix(azurerm_dns_a_record.hostname[0].fqdn, ".")
}

output "storage_primary_connection_string" {
  value     = module.cdn_storage_account.primary_connection_string
  sensitive = true
}

output "storage_primary_access_key" {
  value     = module.cdn_storage_account.primary_access_key
  sensitive = true
}

output "storage_primary_blob_connection_string" {
  value     = module.cdn_storage_account.primary_blob_connection_string
  sensitive = true
}

output "storage_primary_blob_host" {
  value = module.cdn_storage_account.primary_blob_host
}

output "storage_primary_web_host" {
  value = module.cdn_storage_account.primary_web_host
}

output "name" {
  value = azurerm_cdn_endpoint.this.name
}