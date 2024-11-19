locals {

  repositories = { for r in var.gh_repositories : r.name => r.short_name }

  federations = [
    for repo in var.gh_repositories : {
      repository = repo.name
      subject    = "github-${var.environment_name}"
    }
  ]

  aks_rg_permission = var.kubernetes_deploy.enabled ? {
    "${data.azurerm_kubernetes_cluster.aks[0].resource_group_name}" = [
      "Reader",
      "Azure Kubernetes Service Cluster User Role"
    ]
  } : {}

  custom_permissions = { for perm in var.custom_rg_permissions : perm.rg_name => perm.permissions }


  # to avoid subscription Contributor -> https://github.com/microsoft/azure-container-apps/issues/35
  environment_cd_roles = {
    subscription = [
      "Reader"
    ]
    resource_groups = merge(
      {
        # TODO pèacchetto permission per function
        "${data.azurerm_resource_group.gh_runner_rg.name}" = [
          "Key Vault Reader"
        ],
        "${data.azurerm_resource_group.gh_runner_rg.name}" = [
          "Reader"
        ]
      },
      local.aks_rg_permission,
      local.custom_permissions
    )
  }
}
