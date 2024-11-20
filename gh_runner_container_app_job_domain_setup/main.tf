locals {

}

module "container_app_job" {
  source = "../container_app_job_gh_runner_v2"

  for_each = local.repositories

  env_short        = var.env_short
  environment_name = var.environment_name
  environment_rg   = var.environment_rg
  job = {
    name                 = each.value #short_name
    scale_max_executions = 1
    scale_min_executions = 1
  }
  job_meta = {
    repo                         = each.key #name
    repo_owner                   = var.job_meta.repo_owner
    runner_scope                 = var.job_meta.runner_scope
    target_workflow_queue_length = var.job_meta.target_workflow_queue_length
    github_runner                = var.job_meta.github_runner
  }
  key_vault_name        = var.key_vault.name
  key_vault_rg          = var.key_vault.rg
  key_vault_secret_name = var.key_vault.secret_name
  location              = var.location
  prefix                = var.prefix
  resource_group_name   = var.resource_group_name

  # optionals
  container                   = var.container
  parallelism                 = var.parallelism
  polling_interval_in_seconds = var.polling_interval_in_seconds
  replica_completion_count    = var.replica_completion_count
  replica_retry_limit         = var.replica_retry_limit
  replica_timeout_in_seconds  = var.replica_timeout_in_seconds
  runner_labels               = var.runner_labels
}




# create a module for each 20 repos
module "identity_cd" {
  source = "github.com/pagopa/terraform-azurerm-v3//github_federated_identity?ref=v8.22.0"
  # pagopa-<ENV><DOMAIN>-<COUNTER>-github-<PERMS>-identity
  prefix    = var.prefix
  env_short = var.env_short
  domain    = "${var.domain_name}-${var.gh_identity_suffix}"

  identity_role = "cd"

  github_federations = local.federations

  cd_rbac_roles = {
    subscription_roles = local.environment_cd_roles.subscription
    resource_groups    = local.environment_cd_roles.resource_groups
  }

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "gha_iac_managed_identities" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = module.identity_cd.identity_principal_id

  secret_permissions = ["Get", "List", "Set", ]

  certificate_permissions = ["SetIssuers", "DeleteIssuers", "Purge", "List", "Get"]
  key_permissions = [
    "Get", "List", "Update", "Create", "Import", "Delete", "Encrypt", "Decrypt", "GetRotationPolicy"
  ]

  storage_permissions = []
}

resource "null_resource" "github_runner_app_permissions_to_namespace_cd" {
  for_each = var.kubernetes_deploy.enabled ? var.kubernetes_deploy.namespaces : []

  triggers = {
    aks_id               = data.azurerm_kubernetes_cluster.aks[0].id
    service_principal_id = module.identity_cd.identity_client_id
    namespace            = each.value
    version              = "v2"
  }

  provisioner "local-exec" {
    command = <<EOT
      az role assignment create --role "Azure Kubernetes Service RBAC Admin" \
      --assignee ${self.triggers.service_principal_id} \
      --scope ${self.triggers.aks_id}/namespaces/${self.triggers.namespace}

      az role assignment list --role "Azure Kubernetes Service RBAC Admin"  \
      --scope ${self.triggers.aks_id}/namespaces/${self.triggers.namespace}
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      az role assignment delete --role "Azure Kubernetes Service RBAC Admin" \
      --assignee ${self.triggers.service_principal_id} \
      --scope ${self.triggers.aks_id}/namespaces/${self.triggers.namespace}
    EOT
  }

  depends_on = [
    module.identity_cd
  ]
}
