# Migration guide for generic resources

<https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/3.0-upgrade-guide#new-resources-and-data-sources-for-app-service>

## azurerm_log_analytics_workspace

Is possible that you need to delete the state and re-import

```sh
terraform state rm azurerm_log_analytics_workspace.log_analytics_workspace
```

### 🔥 azurerm_application_insights

This resource will be recreated, because the azurerm_log_analytics_workspace is imported

### 🔥 azurerm_public_ip

1. Is possible that the new resource want to recreate the ips because you need to put the `zones` parameter as list [1,2,3]

1. Is possible that you need to delete the state and re-import

### 🔥 azurerm_dns_a_record

1. Is better that you delete the state for this resource and re-import.

### azurerm_api_management_custom_domain

Attributes changed

* `proxy` -> `gateway`

### azurerm_monitor_diagnostic_setting

Some time you need to re-import this kind of resource. And the import don't go well.

Because following the import instruction, the resource ID to import is wrong.

For example with something like this

```ts
2021-09-08T09:50:34.362+0200 [WARN]  ValidateProviderConfig from "provider[\"registry.terraform.io/hashicorp/azurerm\"]" changed the config value, but that value is unused
azurerm_monitor_diagnostic_setting.resource_health_alert: Importing from ID "subscriptions/************************/providers/microsoft.insights/diagnosticSettings/Resource health diagnostics develop"...
azurerm_monitor_diagnostic_setting.resource_health_alert: Import prepared!
  Prepared azurerm_monitor_diagnostic_setting for import
azurerm_monitor_diagnostic_setting.resource_health_alert: Refreshing state... [id=subscriptions/************************/providers/microsoft.insights/diagnosticSettings/Resource health diagnostics develop]
╷
│ Error: Expected the Monitor Diagnostics ID to be in the format `{resourceId}|{name}` but got 1 segments
```

The correct id is like this `{resourceId}|{name}` for example `/subscriptions/ac17914c-79bf-48fa-831e-1359ef74c1d5/resourceGroups/dvopla-d-postgres-dbs-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/dvopla-d-public-pgflex|LogSecurity`

```sh
sh terraform.sh import dev 'module.postgres_flexible_server_public[0].azurerm_monitor_diagnostic_setting.this[0]' '/subscriptions/ac17914c-79bf-48fa-831e-1359ef74c1d5/resourceGroups/dvopla-d-postgres-dbs-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/dvopla-d-public-pgflex|LogSecurity'
```

### azurerm_function_app_host_keys

The deprecated field `master_key` will be removed in favour of the `primary_key` property.
