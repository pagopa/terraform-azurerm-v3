output "id" {
  value = azurerm_redis_cache.this.id
}

output "name" {
  value = azurerm_redis_cache.this.name
}

output "location" {
  value = azurerm_redis_cache.this.location
}

output "resource_group_name" {
  value = azurerm_redis_cache.this.resource_group_name
}

output "primary_access_key" {
  value     = azurerm_redis_cache.this.primary_access_key
  sensitive = true
}

output "primary_connection_string" {
  value     = azurerm_redis_cache.this.primary_connection_string
  sensitive = true
}

output "hostname" {
  value = azurerm_redis_cache.this.hostname
}

output "port" {
  value = azurerm_redis_cache.this.port
}

output "ssl_port" {
  value = azurerm_redis_cache.this.ssl_port
}
