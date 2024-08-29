resource "azurerm_user_assigned_identity" "this" {
  name = var.identity_name

  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_key_vault_access_policy" "this" {
  count = var.key_vault_id == null ? 0 : 1

  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id

  # The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault.
  object_id = azurerm_user_assigned_identity.this.principal_id

  certificate_permissions = var.certificate_permissions
  key_permissions         = var.key_permissions
  secret_permissions      = var.secret_permissions

  depends_on = [
    azurerm_user_assigned_identity.this
  ]
}

resource "null_resource" "create_pod_identity" {
  triggers = {
    resource_group = var.resource_group_name
    cluster_name   = var.cluster_name
    namespace      = var.namespace
    name           = var.identity_name
    identity_id    = azurerm_user_assigned_identity.this.id
  }

  provisioner "local-exec" {
    command = <<EOT
      az aks pod-identity add \
        --resource-group ${self.triggers.resource_group} \
        --cluster-name ${self.triggers.cluster_name} \
        --namespace ${self.triggers.namespace} \
        --name ${self.triggers.name} \
        --verbose \
        --identity-resource-id ${self.triggers.identity_id}

      echo "✅ pod identity created"

      az aks pod-identity list \
        --resource-group ${self.triggers.resource_group} \
        --cluster-name ${self.triggers.cluster_name} \
        --query 'podIdentityProfile.userAssignedIdentities[].{name:name, state:provisioningState}' || true
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      az aks pod-identity delete \
        --verbose \
        --resource-group ${self.triggers.resource_group} \
        --cluster-name ${self.triggers.cluster_name} \
        --namespace ${self.triggers.namespace} \
        --name ${self.triggers.name} && echo "✅ podIdentity deleted" || echo "❌ Error during podIdentity delete"

      az aks pod-identity list \
        --resource-group ${self.triggers.resource_group} \
        --cluster-name ${self.triggers.cluster_name} \
        --query 'podIdentityProfile.userAssignedIdentities[].{name:name, state:provisioningState}' || true
    EOT
  }

  depends_on = [
    azurerm_user_assigned_identity.this
  ]
}
