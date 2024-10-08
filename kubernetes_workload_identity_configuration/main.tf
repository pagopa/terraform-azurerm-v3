resource "null_resource" "workload_identity_kv_conf_check" {
  count = var.key_vault_configuration_enabled == true && var.key_vault_certificate_permissions == null && var.key_vault_key_permissions == null && var.key_vault_secret_permissions == null ? "⚠️ At least one kv policy configuration must be configured" : 0
}

resource "null_resource" "workload_identity_name_check" {
  count = var.workload_identity_name == null && var.workload_identity_name_prefix == null ? "⚠️ At least one between name prefix or name must be fill" : 0
}

#------------------------------------------------------------------------------

data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  resource_group_name = var.aks_resource_group_name
}

data "azurerm_user_assigned_identity" "this" {
  name                = local.workload_identity_name
  resource_group_name = var.workload_identity_resource_group_name
}

#------------------------------------------------------------------------------

resource "azurerm_federated_identity_credential" "workload_identity_federation" {
  name                = local.workload_identity_name
  resource_group_name = var.workload_identity_resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = data.azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = data.azurerm_user_assigned_identity.this.id
  subject             = "system:serviceaccount:${var.namespace}:${local.workload_identity_name}"

  depends_on = [
    data.azurerm_user_assigned_identity.this
  ]
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
        "azure.workload.identity/client-id" = data.azurerm_user_assigned_identity.this.client_id
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

  depends_on = [
    data.azurerm_user_assigned_identity.this
  ]
}

#
# 🔒 KV
#

resource "azurerm_key_vault_access_policy" "this" {
  count        = var.key_vault_configuration_enabled ? 1 : 0
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_user_assigned_identity.this.tenant_id

  # The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault.
  object_id = data.azurerm_user_assigned_identity.this.principal_id

  certificate_permissions = var.key_vault_certificate_permissions
  key_permissions         = var.key_vault_key_permissions
  secret_permissions      = var.key_vault_secret_permissions

  depends_on = [
    data.azurerm_user_assigned_identity.this
  ]
}

#tfsec:ignore:azure-keyvault-ensure-secret-expiry tfsec:ignore:azure-keyvault-content-type-for-secret
resource "azurerm_key_vault_secret" "workload_identity_client_id" {
  count = var.key_vault_configuration_enabled ? 1 : 0

  key_vault_id = var.key_vault_id
  name         = local.workload_identity_client_id_secret_name_title
  value        = data.azurerm_user_assigned_identity.this.client_id
}

#tfsec:ignore:azure-keyvault-ensure-secret-expiry tfsec:ignore:azure-keyvault-content-type-for-secret
resource "azurerm_key_vault_secret" "workload_identity_service_account_name" {
  count = var.key_vault_configuration_enabled ? 1 : 0

  key_vault_id = var.key_vault_id
  name         = local.workload_identity_service_account_name_title
  value        = local.workload_identity_name
}
