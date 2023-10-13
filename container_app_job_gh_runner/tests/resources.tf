module "runner" {
  source = "../" # change me with module URI

  location  = var.location
  prefix    = var.prefix
  env_short = substr(random_id.unique.hex, 0, 1) # change me with your env

  # set reference to the secret which holds the GitHub PAT with access to your repos
  key_vault = {
    resource_group_name = var.key_vault.resource_group_name
    name                = var.key_vault.name
    secret_name         = var.key_vault.secret_name
  }

  # this creates a subnet in the specified vnet using CIDR block set here. Set /23 CIDR block
  network = {
    rg_vnet      = var.network.rg_vnet
    vnet         = var.network.vnet
    cidr_subnets = var.network.cidr_subnets
  }

  # set reference to the log analytics workspace you want to use to log
  environment = {
    workspace_id = var.environment.workspace_id
    customerId   = var.environment.customerId
    sharedKey    = var.environment.sharedKey
  }

  # set app properties - especially the list of repos to support
  app = {
    repos      = var.app.repos
    repo_owner = var.app.repo_owner
  }

  tags = var.tags
}
