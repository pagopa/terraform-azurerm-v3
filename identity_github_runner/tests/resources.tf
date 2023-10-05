resource "azurerm_resource_group" "rg" {
  name     = "${local.project}-identity-rg"
  location = var.location

  tags = var.tags
}

module "identity-ci" {
  source = "../"

  prefix        = var.prefix
  env_short     = random_id.unique.hex
  identity_role = "ci"
  github = {
    repository = var.repository
    subject    = var.prefix
  }

  tags = var.tags
}

module "identity-cd" {
  source = "../"

  prefix        = var.prefix
  env_short     = random_id.unique.hex
  identity_role = "cd"
  github = {
    repository = var.repository
    subject    = var.prefix
  }

  tags = var.tags
}
