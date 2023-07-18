data "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
}

data "azurerm_resource_group" "aks_rg" {
  name = var.resource_group_name
}

# ------------------------------------------------------
resource "azurerm_user_assigned_identity" "this" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name = var.identity_name
}

resource "azurerm_role_assignment" "managed_identity_operator" {
  scope                = data.azurerm_resource_group.aks_rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = data.azurerm_client_config.example.object_id
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
        --identity-resource-id ${self.triggers.identity_id}
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      az aks pod-identity delete \
        --resource-group ${self.triggers.resource_group} \
        --cluster-name ${self.triggers.cluster_name} \
        --namespace ${self.triggers.namespace} \
        --name ${self.triggers.name}
    EOT
  }
}
