# Migration guide for generic resources

## azurerm_log_analytics_workspace

Is possible that you need to delete the state and import

```sh
terraform state rm azurerm_log_analytics_workspace.log_analytics_workspace
```

### 🔥 azurerm_application_insights

This resource will be recreated, because the azurerm_log_analytics_workspace is imported
