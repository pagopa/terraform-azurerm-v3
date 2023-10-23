output "identity_ci_resource_group_name" {
  value       = module.identity-ci.identity_resource_group
  description = "User Managed Identity resource group"
}

output "identity_ci_app_name" {
  value       = module.identity-ci.identity_app_name
  description = "User Managed Identity name"
}

output "identity_ci_client_id" {
  value       = module.identity-ci.identity_client_id
  description = "User Managed Identity client id"
}

output "identity_ci_principal_id" {
  value       = module.identity-ci.identity_principal_id
  description = "User Managed Identity principal id"
}

output "identity_cd_resource_group_name" {
  value       = module.identity-cd.identity_resource_group
  description = "User Managed Identity resource group"
}

output "identity_cd_app_name" {
  value       = module.identity-cd.identity_app_name
  description = "User Managed Identity name"
}

output "identity_cd_client_id" {
  value       = module.identity-cd.identity_client_id
  description = "User Managed Identity client id"
}

output "identity_cd_principal_id" {
  value       = module.identity-cd.identity_principal_id
  description = "User Managed Identity principal id"
}
