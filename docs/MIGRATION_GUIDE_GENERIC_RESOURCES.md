# Migration guide for generic resources

## azurerm_log_analytics_workspace

Is possible that you need to delete the state and import

```sh
terraform state rm azurerm_log_analytics_workspace.log_analytics_workspace
```

### 🔥 azurerm_application_insights

This resource will be recreated, because the azurerm_log_analytics_workspace is imported

### 🔥 azurerm_public_ip

Is better that you delete the state for this resource and re-import. The behavior is random if you try to use as is.
