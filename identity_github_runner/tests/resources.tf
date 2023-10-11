# https://pagopa.atlassian.net/wiki/spaces/Technology/pages/734527975/GitHub+OIDC+OP

module "identity-ci" {
  source = "../" # change me with module URI

  location      = var.location
  prefix        = var.prefix
  env_short     = random_id.unique.hex # change me with your env
  identity_role = "ci"                 # possible values: `ci` and `cd`. Choose yours depending on the pipeline kind
  github = {
    repository        = var.repository # your repository name
    credentials_scope = "environment"  # (optional) federation scope. Module's default is `environment`; other values are branch, pr and tag
    subject           = var.prefix     # change me. value of the credential scope. If environment is used as scope, set your GitHub environment name
  }

  tags = var.tags
}

# everything as above, except for the role
module "identity-cd" {
  source = "../"

  location      = var.location
  prefix        = var.prefix
  env_short     = random_id.unique.hex
  identity_role = "cd"
  github = {
    repository = var.repository
    subject    = var.prefix
  }

  tags = var.tags
}
