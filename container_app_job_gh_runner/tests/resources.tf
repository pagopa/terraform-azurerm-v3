module "runner" {
  source = "../"

  location  = var.location
  prefix    = var.prefix
  env_short = substr(random_id.unique.hex, 0, 1)

  key_vault = {
    resource_group_name = var.key_vault.resource_group_name
    name                = var.key_vault.name
    secret_name         = var.key_vault.secret_name
  }

  network = {
    rg_vnet      = var.network.rg_vnet
    vnet         = var.network.vnet
    cidr_subnets = var.network.cidr_subnets
  }

  environment = {
    workspace_id = var.environment.workspace_id
    customerId   = var.environment.customerId
    sharedKey    = var.environment.sharedKey
  }

  app = {
    repos      = var.app.repos
    repo_owner = var.app.repo_owner
  }

  tags = var.tags
}
