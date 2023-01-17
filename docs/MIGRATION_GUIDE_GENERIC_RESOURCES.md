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

* `proxy` -> `gateway`
