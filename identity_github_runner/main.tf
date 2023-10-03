resource "azurerm_user_assigned_identity" "identity" {
  location            = var.location
  name                = "${var.project}-github-identity-${var.identity_role}"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_role_assignment" "identity_role_assignment" {
  for_each             = toset(var.identity_role == "ci" ? var.ci_roles : var.cd_roles)
  scope                = data.azurerm_subscription.current.id
  role_definition_name = each.key
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}

resource "azurerm_federated_identity_credential" "identity_credentials" {
  name                = "${var.project}-github-${var.github.repository}-${var.identity_role}"
  resource_group_name = var.resource_group_name
  audience            = var.github.audience
  issuer              = var.github.issuer
  parent_id           = azurerm_user_assigned_identity.identity.id
  subject             = "repo:${var.github.org}/${var.github.repository}:${var.github.credentials_scope}:${var.github.subject}"
}
