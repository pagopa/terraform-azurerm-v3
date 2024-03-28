resource "azapi_resource" "container_app_environment" {
  type      = "Microsoft.App/managedEnvironments@2023-05-01"
  name      = var.name
  location  = var.location
  parent_id = var.resource_group_name

  tags = var.tags

  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = var.log_analytics_workspace.customer_id
          sharedKey  = var.log_analytics_workspace.shared_key
        }
      }
      vnetConfiguration = {
        infrastructureSubnetId = var.subnet_id == null ? null : var.subnet_id
        internal               = var.subnet_id == null ? null : var.internal_load_balancer
      }
      workloadProfiles = var.workload_profiles
      zoneRedundant    = var.subnet_id == null ? null : var.zone_redundant
    }

    kind = "WorkloadProfile"
  })
}
