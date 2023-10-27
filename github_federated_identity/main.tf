data "azurerm_resource_group" "identity_rg" {
  name = local.resource_group_name
}

resource "azurerm_user_assigned_identity" "identity" {
  resource_group_name = data.azurerm_resource_group.identity_rg.name
  location            = data.azurerm_resource_group.identity_rg.location
  name                = local.identity_name

  tags = var.tags
}

resource "azurerm_role_assignment" "identity_subscription_role_assignment" {
  for_each             = var.identity_role == "ci" ? var.ci_rbac_roles.subscription : var.cd_rbac_roles.subscription
  scope                = data.azurerm_subscription.current.id
  role_definition_name = each.value
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}

data "azurerm_resource_group" "resource_group_details" {
  for_each = var.identity_role == "ci" ? var.ci_rbac_roles.resource_groups : var.cd_rbac_roles.resource_groups

  name = each.key
}

locals {
  rg_roles = toset(flatten([
    for rg in data.azurerm_resource_group.resource_group_details : [
      for role in var.identity_role == "ci" ? var.ci_rbac_roles.resource_groups[rg.name] : var.cd_rbac_roles.resource_groups[rg.name] : {
        resource_group_id = rg.id
        role_name         = role
      }
    ]
  ]))
}

resource "azurerm_role_assignment" "identity_rg_role_assignment" {
  for_each             = { for r in local.rg_roles : "${r.resource_group_id}.${r.role_name}" => r } # key must be unique
  scope                = each.value.resource_group_id
  role_definition_name = each.value.role_name
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}

resource "azurerm_federated_identity_credential" "identity_credentials" {
  for_each            = { for g in var.github_federations : "${g.repository}.${g.credentials_scope}.${g.subject}" => g } # key must be unique
  resource_group_name = local.resource_group_name
  name                = "${local.federation_prefix}-${each.value.repository}-${each.value.credentials_scope}-${each.value.subject}"
  audience            = each.value.audience
  issuer              = each.value.issuer
  parent_id           = azurerm_user_assigned_identity.identity.id
  subject             = "repo:${each.value.org}/${each.value.repository}:${each.value.credentials_scope}:${each.value.subject}"
}
