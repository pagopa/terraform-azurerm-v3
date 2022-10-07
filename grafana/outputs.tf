output "name" {
  value = azurerm_dashboard_grafana.this.name
}

output "id" {
  value = azurerm_dashboard_grafana.this.id
}

output "endpoint" {
  value = azurerm_dashboard_grafana.this.endpoint
}

output "version" {
  value = azurerm_dashboard_grafana.this.grafana_version
}

output "outbound_ip" {
  value = azurerm_dashboard_grafana.this.outbound_ip
}
