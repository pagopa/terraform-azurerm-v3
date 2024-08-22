output "user_assigned_identity_id" {
  value = azurerm_user_assigned_identity.this.id
}

output "user_assigned_identity_client_id" {
  value = azurerm_user_assigned_identity.this.client_id
}

output "workload_identity_client_id" {
  value = azurerm_user_assigned_identity.this.client_id
}

output "workload_identity_service_account_name" {
  value = try(kubernetes_service_account_v1.workload_identity_sa[0].metadata[0].name, null)
}

output "workload_identity_service_account_namespace" {
  value = try(kubernetes_service_account_v1.workload_identity_sa[0].metadata[0].namespace, null)
}

output "workload_identity_client_id_secret_name" {
  value = try(azurerm_key_vault_secret.workload_identity_client_id[0].name, null)
}
