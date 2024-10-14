resource "azurerm_user_assigned_identity" "this" {
  name = local.workload_identity_name

  resource_group_name = var.workload_identity_resource_group_name
  location            = var.workload_identity_location
}

resource "azurerm_management_lock" "managed_identity_lock" {
  count = var.enable_lock ? 1 : 0

  name       = local.workload_identity_name
  scope      = azurerm_user_assigned_identity.this.id
  lock_level = "CanNotDelete"
  notes      = "Locked because it's needed by terraform"
}
