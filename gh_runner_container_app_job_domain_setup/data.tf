data "azurerm_kubernetes_cluster" "aks" {
  count               = var.kubernetes_deploy.enabled ? 1 : 0
  name                = var.kubernetes_deploy.cluster_name
  resource_group_name = var.kubernetes_deploy.rg
}

data "azurerm_key_vault" "key_vault" {
  name                = var.key_vault.name
  resource_group_name = var.key_vault.rg
}

data "azurerm_resource_group" "gh_runner_rg" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}
