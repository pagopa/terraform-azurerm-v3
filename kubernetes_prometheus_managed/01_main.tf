#
# AKS Cluster
#
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

data "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  resource_group_name = data.azurerm_resource_group.this.name
}

#
# Azure Monitor Workspace
#
data "azurerm_monitor_workspace" "this" {
  name                = var.monitor_workspace_name
  resource_group_name = var.monitor_workspace_rg
}

resource "azurerm_monitor_data_collection_endpoint" "dce" {
  name                = substr("MSProm-${data.azurerm_resource_group.this.location}-${var.cluster_name}", 0, min(44, length("MSProm-${data.azurerm_resource_group.this.location}-${var.cluster_name}")))
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  kind                = "Linux"
  tags                = var.tags
}

# Logic to determine region mismatch
locals {
  dce_region_mismatch = var.cluster_region != var.amw_region
}

# Create another DCE if the regions don't match and is_private_cluster is true
resource "azurerm_monitor_data_collection_endpoint" "dce_mismatch" {
  count               = (local.dce_region_mismatch && var.is_private_cluster) ? 1 : 0
  name                = substr("MSProm-PL-${data.azurerm_resource_group.this.location}-${var.cluster_name}", 0, min(44, length("MSProm-PL-${data.azurerm_resource_group.this.location}-${var.cluster_name}")))
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.cluster_region
  kind                = "Linux"
  tags                = var.tags
}

resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                        = substr("MSProm-${data.azurerm_resource_group.this.location}-${var.cluster_name}", 0, min(64, length("MSProm-${data.azurerm_resource_group.this.location}-${var.cluster_name}")))
  resource_group_name         = data.azurerm_resource_group.this.name
  location                    = data.azurerm_resource_group.this.location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce.id
  kind                        = "Linux"

  destinations {
    monitor_account {
      monitor_account_id = data.azurerm_monitor_workspace.this.id
      name               = "MonitoringAccount1"
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["MonitoringAccount1"]
  }

  data_sources {
    prometheus_forwarder {
      streams = ["Microsoft-PrometheusMetrics"]
      name    = "PrometheusDataSource"
    }
  }

  description = "DCR for Azure Monitor Metrics Profile (Managed Prometheus)"
  depends_on = [
    azurerm_monitor_data_collection_endpoint.dce
  ]

  tags = var.tags
}

resource "azurerm_monitor_data_collection_rule_association" "dcra" {
  name                    = "MSProm-${data.azurerm_resource_group.this.location}-${var.cluster_name}"
  target_resource_id      = data.azurerm_kubernetes_cluster.this.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr.id
  description             = "Association of data collection rule. Deleting this association will break the data collection for this AKS Cluster."
  depends_on = [
    azurerm_monitor_data_collection_rule.dcr
  ]
}

resource "azurerm_monitor_data_collection_rule_association" "dcra_mismatch" {
  count                       = (local.dce_region_mismatch && var.is_private_cluster) ? 1 : 0
  target_resource_id          = data.azurerm_kubernetes_cluster.this.id
  data_collection_endpoint_id = local.dce_region_mismatch ? azurerm_monitor_data_collection_endpoint.dce_mismatch[0].id : azurerm_monitor_data_collection_endpoint.dce.id
  description                 = "Association of data collection endpoint for private link clusters. Deleting this association will break the data collection for this AKS Cluster."
  depends_on = [
    azurerm_monitor_data_collection_endpoint.dce
  ]
}

data "azurerm_dashboard_grafana" "grafana" {
  name                = var.grafana_name
  resource_group_name = var.grafana_resource_group
}

resource "azurerm_role_assignment" "datareaderrole" {
  scope              = data.azurerm_monitor_workspace.this.id
  role_definition_id = "/subscriptions/${split("/", data.azurerm_monitor_workspace.this.id)[2]}/providers/Microsoft.Authorization/roleDefinitions/b0d8363b-8ddd-447d-831f-62ca05bff136"
  principal_id       = data.azurerm_dashboard_grafana.grafana.identity.0.principal_id
}

# TODO Azure azurerm_dashboard_grafana_managed_private_endpoint release after v4.9.0 of azurerm provider
# https://registry.terraform.io/providers/hashicorp/azurerm/4.9.0/docs/resources/dashboard_grafana_managed_private_endpoint
resource "azapi_resource" "grafana_managed_private_endpoint_ma" {
  type      = "Microsoft.Dashboard/grafana/managedPrivateEndpoints@2023-10-01-preview"
  name      = "pagopa${var.tags["Environment"]}${var.location_short}GrafPam"
  location  = var.location
  tags      = var.tags
  parent_id = data.azurerm_dashboard_grafana.grafana.id
  body = {
    properties = {
      groupIds = [
        "prometheusMetrics"
      ]
      privateLinkResourceId     = data.azurerm_monitor_workspace.this.id
      privateLinkResourceRegion = data.azurerm_monitor_workspace.this.location
      privateLinkServiceUrl     = data.azurerm_monitor_workspace.this.query_endpoint
      requestMessage            = "approval"
    }
  }

  depends_on = [data.azurerm_monitor_workspace.this]
}
