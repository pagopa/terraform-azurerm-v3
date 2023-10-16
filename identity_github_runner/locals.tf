locals {
  name = var.domain == "" ? "${var.prefix}-${var.env_short}" : "${var.prefix}-${var.env_short}-${var.domain}"

  resource_group_name                = "${local.name}-identity-rg"
  identity_name                      = "${local.name}-github-identity-${var.identity_role}"
  federated_identity_credential_name = var.app_name == "" ? "${local.name}-github-${var.github.repository}-${var.identity_role}" : "${local.name}-github-${var.github.repository}-${var.app_name}-${var.identity_role}"
}
