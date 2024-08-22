data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  resource_group_name = var.aks_resource_group_name
}

#------------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "this" {
  name = local.workload_identity_name

  resource_group_name = var.workload_identity_resource_group_name
  location            = data.azurerm_kubernetes_cluster.aks.location
}

resource "azurerm_federated_identity_credential" "workload_identity_federation" {
  name                = local.workload_identity_name
  resource_group_name = var.workload_identity_resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = data.azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.this.id
  subject             = "system:serviceaccount:${var.namespace}:${local.workload_identity_name}"
}

#
# K8s service account
#
resource "kubernetes_service_account_v1" "workload_identity_sa" {
  count = var.service_account_configuration_enabled ? 1 : 0
  metadata {
    name      = local.workload_identity_name
    namespace = var.namespace
    annotations = merge(
      {
      "azure.workload.identity/client-id" = azurerm_user_assigned_identity.this.client_id
      },
      var.service_account_annotations
    )

    labels = var.service_account_labels
  }

  dynamic "image_pull_secret" {
    for_each = var.service_account_image_pull_secret_names
    content {
      name = image_pull_secret.key
    }
  }
}

#
# 🔒 KV
#

resource "azurerm_key_vault_access_policy" "this" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_user_assigned_identity.this.tenant_id

  # The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault.
  object_id = azurerm_user_assigned_identity.this.principal_id

  certificate_permissions = var.key_vault_certificate_permissions
  key_permissions         = var.key_vault_key_permissions
  secret_permissions      = var.key_vault_secret_permissions

  depends_on = [
    azurerm_user_assigned_identity.this
  ]
}

resource "azurerm_key_vault_secret" "workload_identity_client_id" {
  key_vault_id = var.key_vault_id
  name         = "${local.workload_identity_name}-client-id"
  value        = azurerm_user_assigned_identity.this.client_id
}
