resource "azurerm_resource_group" "rg" {
  name     = "${local.project}-rg"
  location = var.location

  tags = var.tags
}

module "identity-ci" {
  source = "../"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  project             = local.project
  identity_role       = "ci"
  github = {
    repository = "io-infra"
    subject    = "dev"
  }

  tags = var.tags
}

module "identity-cd" {
  source = "../"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  project             = local.project
  identity_role       = "cd"
  github = {
    repository = "io-infra"
    subject    = "dev"
  }

  tags = var.tags
}
