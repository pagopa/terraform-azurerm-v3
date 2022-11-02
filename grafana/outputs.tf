output "name" {
  value = azurerm_dashboard_grafana.this.name
}

output "id" {
  value = azurerm_dashboard_grafana.this.id
}

output "endpoint" {
  description = "https endpoint"
  value = azurerm_dashboard_grafana.this.endpoint
}

output "hostname" {
  value = trimprefix(azurerm_dashboard_grafana.this.endpoint, "https://")
}

output "version" {
  value = azurerm_dashboard_grafana.this.grafana_version
}

output "outbound_ip" {
  value = azurerm_dashboard_grafana.this.outbound_ip
}

output "principal_id" {
  value = azurerm_dashboard_grafana.this.identity[0].principal_id
}
