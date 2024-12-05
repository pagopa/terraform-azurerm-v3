locals {

  repositories = { for r in var.gh_repositories : r.name => r.short_name }

  federations = [
    for repo in var.gh_repositories : {
      repository = repo.name
      subject    = var.gh_env
    }
  ]

  aks_rg_permission = var.kubernetes_deploy.enabled ? {
    "${data.azurerm_kubernetes_cluster.aks[0].resource_group_name}" = [
      "Reader",
      "Azure Kubernetes Service Cluster User Role"
    ]
  } : {}

  custom_permissions = { for perm in var.custom_rg_permissions : perm.rg_name => perm.permissions }
  domain_sec_rg_permission = var.domain_security_rg_name != null ? {
    "${var.domain_security_rg_name}" = [
      "Key Vault Reader"
    ]
  } : {}


  environment_cd_roles = {
    subscription = [
      "Contributor"
    ]
    resource_groups = merge(
      {
        "${data.azurerm_resource_group.gh_runner_rg.name}" = [
          "Key Vault Reader"
        ],
        "${data.azurerm_resource_group.gh_runner_rg.name}" = [
          "Reader"
        ]
      },
      local.aks_rg_permission,
      local.custom_permissions,
      local.domain_sec_rg_permission
    )
  }
}
