//
// Locals
//
locals {
  project  = "${var.project}-${var.env}" #alias
  app_name = "github-${var.github_org}-${var.github_repository}-${var.env}"

  environment_cd_resource_group_roles = distinct(flatten([
    for rg, role_list in var.environment_cd_roles.resource_groups : [
      for role in role_list : {
        resource_group = rg
        role           = role
      }
    ]
  ]))
}

//
// Data
//
data "azurerm_resource_group" "environment_cd_resource_groups" {
  for_each = toset([for rg, role_list in var.environment_cd_roles.resource_groups : rg])
  name     = each.value
}

data "azurerm_resource_group" "github_runner_rg" {
  name = "${var.prefix}-${var.env_short}-github-runner-rg"
}

data "github_organization_teams" "all" {
  root_teams_only = true
  summary_only    = true
}

//
// Application environmente CD
//
resource "azuread_application" "environment_cd" {
  display_name = "${local.app_name}-cd"
}

resource "azuread_service_principal" "environment_cd" {
  application_id = azuread_application.environment_cd.application_id
}

resource "azuread_application_federated_identity_credential" "environment_cd" {
  application_object_id = azuread_application.environment_cd.object_id
  display_name          = "github-federated"
  description           = "github-federated"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.github_org}/${var.github_repository}:environment:${var.env}-cd"
}

resource "azurerm_role_assignment" "environment_cd_subscription" {
  for_each             = toset(var.environment_cd_roles.subscription)
  scope                = data.azurerm_subscription.current.id
  role_definition_name = each.key
  principal_id         = azuread_service_principal.environment_cd.object_id
}

resource "azurerm_role_assignment" "environment_cd_resource_group" {
  for_each             = { for entry in local.environment_cd_resource_group_roles : "${entry.role}.${entry.resource_group}" => entry }
  scope                = data.azurerm_resource_group.environment_cd_resource_groups[each.value.resource_group].id
  role_definition_name = each.value.role
  principal_id         = azuread_service_principal.environment_cd.object_id
}

//
// Application environment runner
//
resource "azuread_application" "environment_runner" {
  display_name = "${local.app_name}-runner"
}

resource "azuread_service_principal" "environment_runner" {
  application_id = azuread_application.environment_runner.application_id
}

resource "azuread_application_federated_identity_credential" "environment_runner" {
  application_object_id = azuread_application.environment_runner.object_id
  display_name          = "github-federated"
  description           = "github-federated"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.github_org}/${var.github_repository}:environment:${var.env}-runner"
}

resource "azurerm_role_assignment" "environment_runner_github_runner_rg" {
  scope                = data.azurerm_resource_group.github_runner_rg.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.environment_runner.object_id
}

//
// Github environment CD
//
resource "github_repository_environment" "github_repository_environment_cd" {
  environment = "${var.env}-cd"
  repository  = var.github_repository
  # filter teams reviewers from github_organization_teams
  # if reviewers_teams is null no reviewers will be configured for environment
  dynamic "reviewers" {
    for_each = (var.github_repository_environment_cd.reviewers_teams == null ? [] : [1])
    content {
      teams = matchkeys(
        data.github_organization_teams.all.teams[*].id,
        data.github_organization_teams.all.teams[*].slug,
        var.github_repository_environment_cd.reviewers_teams
      )
    }
  }
  deployment_branch_policy {
    protected_branches     = var.github_repository_environment_cd.protected_branches
    custom_branch_policies = var.github_repository_environment_cd.custom_branch_policies
  }
}

#tfsec:ignore:github-actions-no-plain-text-action-secrets # not real secret
resource "github_actions_environment_secret" "azure_cd_tenant_id" {
  repository      = var.github_repository
  environment     = "${var.env}-cd"
  secret_name     = "AZURE_TENANT_ID"
  plaintext_value = data.azurerm_client_config.current.tenant_id
}

#tfsec:ignore:github-actions-no-plain-text-action-secrets # not real secret
resource "github_actions_environment_secret" "azure_cd_subscription_id" {
  repository      = var.github_repository
  environment     = "${var.env}-cd"
  secret_name     = "AZURE_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_subscription.current.subscription_id
}

#tfsec:ignore:github-actions-no-plain-text-action-secrets # not real secret
resource "github_actions_environment_secret" "azure_cd_client_id" {
  repository      = var.github_repository
  environment     = "${var.env}-cd"
  secret_name     = "AZURE_CLIENT_ID"
  plaintext_value = azuread_service_principal.environment_cd.application_id
}

//
// Github environment runner
//
resource "github_repository_environment" "github_repository_environment_runner" {
  environment = "${var.env}-runner"
  repository  = var.github_repository
  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

#tfsec:ignore:github-actions-no-plain-text-action-secrets # not real secret
resource "github_actions_environment_secret" "azure_runner_tenant_id" {
  repository      = var.github_repository
  environment     = "${var.env}-runner"
  secret_name     = "AZURE_TENANT_ID"
  plaintext_value = data.azurerm_client_config.current.tenant_id
}

#tfsec:ignore:github-actions-no-plain-text-action-secrets # not real secret
resource "github_actions_environment_secret" "azure_runner_subscription_id" {
  repository      = var.github_repository
  environment     = "${var.env}-runner"
  secret_name     = "AZURE_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_subscription.current.subscription_id
}

#tfsec:ignore:github-actions-no-plain-text-action-secrets # not real secret
resource "github_actions_environment_secret" "azure_runner_client_id" {
  repository      = var.github_repository
  environment     = "${var.env}-runner"
  secret_name     = "AZURE_CLIENT_ID"
  plaintext_value = azuread_service_principal.environment_runner.application_id
}

#tfsec:ignore:github-actions-no-plain-text-action-secrets # not real secret
resource "github_actions_environment_secret" "azure_runner_container_app_environment_name" {
  repository      = var.github_repository
  environment     = "${var.env}-runner"
  secret_name     = "AZURE_CONTAINER_APP_ENVIRONMENT_NAME"
  plaintext_value = "${local.project}-github-runner-cae"
}

#tfsec:ignore:github-actions-no-plain-text-action-secrets # not real secret
resource "github_actions_environment_secret" "azure_runner_resource_group_name" {
  repository      = var.github_repository
  environment     = "${var.env}-runner"
  secret_name     = "AZURE_RESOURCE_GROUP_NAME"
  plaintext_value = "${local.project}-github-runner-rg"
}
