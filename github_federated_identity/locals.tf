locals {
  name = var.domain == "" ? "${var.prefix}-${var.env_short}" : "${var.prefix}-${var.env_short}-${var.domain}"

  resource_group_name = "${var.prefix}-${var.env_short}-identity-rg"
  identity_name       = var.app_name == "" ? "${local.name}-github-${var.identity_role}-identity" : "${local.name}-${var.app_name}-github-${var.identity_role}-identity"
  # federation_prefix   = var.app_name == "" ? "${local.name}-github" : "${local.name}-${var.app_name}-github"
  federation_prefix = "${local.name}-github"
}
