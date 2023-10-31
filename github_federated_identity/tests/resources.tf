# https://pagopa.atlassian.net/wiki/spaces/Technology/pages/734527975/GitHub+OIDC+OP

# resource group name should follow the convention specified in README.md file
resource "azurerm_resource_group" "identity_rg" {
  name     = var.domain == "" ? "${var.prefix}-${local.env_short}-identity-rg" : "${var.prefix}-${local.env_short}-${var.domain}-identity-rg"
  location = var.location
}

module "identity-ci" {
  source = "../" # change me with module URI

  prefix    = var.prefix
  env_short = local.env_short # change me with your env
  domain    = var.domain      # optional, default is empty string

  identity_role = "ci" # possible values: `ci` and `cd`. Choose yours depending on the pipeline kind

  github_federations = [
    {
      repository        = var.repository # your repository name
      credentials_scope = "environment"  # (optional) federation scope. Module's default is `environment`; other values are branch, pr and tag
      subject           = var.prefix     # change me. value of the credential scope. If environment is used as scope, set your GitHub environment name
    }
  ]

  # ci/d_rbac_roles is optional. Default gives Reader (CI) and Contributor (CD) roles on current subscription

  tags = var.tags
}

# everything as above, except for write roles
module "identity-cd" {
  source = "../"

  prefix    = var.prefix
  env_short = local.env_short

  identity_role = "cd"

  cd_rbac_roles = {         # explicit definition, so default Contributor role is not assigned to the current subscription
    subscription_roles = [] # empty array means no permission over the current subscription
    resource_groups = {     # map of resource groups with list of roles to assign
      "${var.prefix}-${local.env_short}-identity-rg" = [
        "Contributor"
      ]
    }
  }

  github_federations = [
    {
      repository = var.repository
      subject    = var.prefix
    }
  ]

  tags = var.tags
}
