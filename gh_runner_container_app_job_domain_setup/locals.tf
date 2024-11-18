locals {
  federations = [
    for repo in var.gh_repositories : {
      repository = repo.name
      subject    = "github-${var.environment_name}"
    }
  ]

  # to avoid subscription Contributor -> https://github.com/microsoft/azure-container-apps/issues/35
  environment_cd_roles = {
    subscription = [
      "Reader"
    ]
    resource_groups = {
      "${data.azurerm_resource_group.gh_runner_rg.name}" = [
        "Key Vault Reader"
      ],
      "${data.azurerm_kubernetes_cluster.aks[0].resource_group_name}" = [
        "Reader",
        "Azure Kubernetes Service Cluster User Role"
      ],
      "${data.azurerm_resource_group.gh_runner_rg.name}" = [
        "Reader"
      ]
    }
  }
}
