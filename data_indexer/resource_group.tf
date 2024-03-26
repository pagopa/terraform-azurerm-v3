resource "azurerm_resource_group" "this" {
  name     = "${var.name}-di-rg"
  location = var.location
}