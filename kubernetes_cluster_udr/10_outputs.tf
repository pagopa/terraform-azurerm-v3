output "id" {
  value = azurerm_kubernetes_cluster.this.id
}

output "name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "fqdn" {
  value       = azurerm_kubernetes_cluster.this.fqdn
  description = "The FQDN of the Azure Kubernetes Managed Cluster."
}

output "private_fqdn" {
  value       = azurerm_kubernetes_cluster.this.private_fqdn
  description = "The FQDN for the Kubernetes Cluster when private link has been enabled, which is only resolvable inside the Virtual Network used by the Kubernetes Cluster."
}

output "kubelet_identity_id" {
  value       = azurerm_kubernetes_cluster.this.kubelet_identity.0.object_id
  description = "The Object ID of the user-defined Managed Identity assigned to the Kubelets.If not specified a Managed Identity is created automatically. Changing this forces a new resource to be created."
}

output "identity_principal_id" {
  value       = azurerm_kubernetes_cluster.this.identity.0.principal_id
  description = "The Principal ID associated with this Managed Service Identity."
}

output "managed_resource_group_name" {
  value       = azurerm_kubernetes_cluster.this.node_resource_group
  description = " The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster."
}

output "managed_private_dns_zone_name" {
  value       = local.managed_private_dns_zone_name
  description = "The managed private dns zone name for the Kubernetes Cluster when private link has been enabled. Derived from private_fqdn"
}
