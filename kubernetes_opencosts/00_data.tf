
data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  resource_group_name = var.aks_rg_name
}

data "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.kubernetes_namespace
  }
}
