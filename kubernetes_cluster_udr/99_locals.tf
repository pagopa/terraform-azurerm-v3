locals {
  aks_fqdn_levels               = length(split(".", azurerm_kubernetes_cluster.this.private_fqdn))
  managed_private_dns_zone_name = join(".", slice(split(".", azurerm_kubernetes_cluster.this.private_fqdn), 1, local.aks_fqdn_levels))
}
