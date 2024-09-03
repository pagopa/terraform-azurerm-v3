#
# User assigned identity
#
output "user_assigned_identity_id" {
  value = data.azurerm_user_assigned_identity.this.id
}

output "user_assigned_identity_name" {
  value = data.azurerm_user_assigned_identity.this.name
}

output "user_assigned_identity_resource_group_name" {
  value = data.azurerm_user_assigned_identity.this.resource_group_name
}

output "user_assigned_identity_client_id" {
  value = data.azurerm_user_assigned_identity.this.client_id
}

output "user_assigned_identity_principal_id" {
  value = data.azurerm_user_assigned_identity.this.principal_id
}

#
# Workload identity
#
output "workload_identity_client_id" {
  value = data.azurerm_user_assigned_identity.this.client_id
}

output "workload_identity_principal_id" {
  value = data.azurerm_user_assigned_identity.this.principal_id
}

output "workload_identity_service_account_name" {
  value = try(kubernetes_service_account_v1.workload_identity_sa[0].metadata[0].name, null)
}

output "workload_identity_service_account_namespace" {
  value = try(kubernetes_service_account_v1.workload_identity_sa[0].metadata[0].namespace, null)
}

#
# KV
#
output "workload_identity_client_id_secret_name" {
  value = data.azurerm_user_assigned_identity.this.client_id
}
