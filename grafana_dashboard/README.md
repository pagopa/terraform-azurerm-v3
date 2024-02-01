# Grafana Managed Automatic Dashboard by tag

This module allow the creation of Grafana Dashboard to all "grafana = yes" tagged resources based on json template

## Configurations

## How to use it

```ts
module "auto_dashboard" {

  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//grafana_dashboard?ref=xxx"

  grafana_url = azurerm_dashboard_grafana.grafana_dashboard.endpoint
  grafana_api_key = "GRAFANA_SERVICE_ACCOUNT_TOKEN"
  prefix  = var.prefix
  monitor_workspace = data.azurerm_log_analytics_workspace.log_analytics.id
  dashboard_directory_path = "pagopa"
}

```
# Add a dashboard JSON template

Create e grafana dashboard json template and put in "dashboard" or "custom" directory.
N.B. the name of JSON template file MUST be as Azure Namespace type replacing "/" with "_"
example:

    Microsoft.ContainerService/managedClusters -> Microsoft.ContainerService_managedClusters.json

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | <= 2.3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [grafana_dashboard.azure_monitor_grafana](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_folder.domainsfolder](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [azurerm_resources.sub_resources](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dashboard_directory_path"></a> [dashboard\_directory\_path](#input\_dashboard\_directory\_path) | path for dashboard template | `string` | `"dashboard"` | no |
| <a name="input_grafana_api_key"></a> [grafana\_api\_key](#input\_grafana\_api\_key) | Grafana Managed Service Account key | `string` | n/a | yes |
| <a name="input_grafana_url"></a> [grafana\_url](#input\_grafana\_url) | Grafana Managed url | `string` | n/a | yes |
| <a name="input_monitor_workspace_id"></a> [monitor\_workspace\_id](#input\_monitor\_workspace\_id) | Azure Log Analytics workspace id | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | product label used for dashboard folder and title | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
