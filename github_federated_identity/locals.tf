locals {
  name = var.domain == "" ? "${var.prefix}-${var.env_short}" : "${var.prefix}-${var.env_short}-${var.domain}"

  resource_group_name = "${local.name}-identity-rg"
  identity_name       = "${local.name}-github-identity-${var.identity_role}"
  federation_prefix   = "${local.name}-github"
}
