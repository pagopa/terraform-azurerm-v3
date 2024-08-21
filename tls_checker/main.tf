resource "helm_release" "helm_this" {

  count = var.helm_chart_present ? 1 : 0

  namespace  = var.namespace
  name       = local.helm_chart_name
  chart      = "microservice-chart"
  repository = "https://pagopa.github.io/aks-microservice-chart-blueprint"
  version    = local.chart_version
  timeout      = 120
  force_update = true

  values = [
    var.workload_identity_enabled ?
    templatefile("${path.module}/templates/cert-mounter-workload-identity.yaml.tpl",
      {
        namespace                                                 = var.namespace
        image_name                                                = var.helm_chart_image_name
        image_tag                                                 = var.helm_chart_image_tag
        website_site_name                                         = var.https_endpoint
        time_trigger                                              = var.time_trigger
        function_name                                             = var.https_endpoint
        region                                                    = var.location_string
        expiration_delta_in_days                                  = var.expiration_delta_in_days
        host                                                      = var.https_endpoint
        keyvault_name                                             = var.keyvault_name
        keyvault_tenant_id                                        = var.keyvault_tenant_id
        kv_secret_name_for_application_insights_connection_string = var.kv_secret_name_for_application_insights_connection_string
        SERVICE_ACCOUNT_NAME = var.workload_identity_service_account_name
        WORKLOAD_IDENTITY_CLIENT_ID = var.workload_identity_client_id
    }):
    templatefile("${path.module}/templates/tls-cert.yaml.tpl",
    {
      namespace                                                 = var.namespace
      image_name                                                = var.helm_chart_image_name
      image_tag                                                 = var.helm_chart_image_tag
      website_site_name                                         = var.https_endpoint
      time_trigger                                              = var.time_trigger
      function_name                                             = var.https_endpoint
      region                                                    = var.location_string
      expiration_delta_in_days                                  = var.expiration_delta_in_days
      host                                                      = var.https_endpoint
      keyvault_name                                             = var.keyvault_name
      keyvault_tenant_id                                        = var.keyvault_tenant_id
      kv_secret_name_for_application_insights_connection_string = var.kv_secret_name_for_application_insights_connection_string
  })
  ]
}

#
# 📢 Alert
#
resource "azurerm_monitor_metric_alert" "alert_this" {
  name                = local.alert_name
  resource_group_name = var.application_insights_resource_group
  scopes              = [var.application_insights_id]
  description         = "Whenever the average availabilityresults/availabilitypercentage is less than 50%"
  severity            = 0
  frequency           = "PT5M"
  auto_mitigate       = false
  enabled             = var.alert_enabled

  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "availabilityResults/availabilityPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 50

    dimension {
      name     = "availabilityResult/name"
      operator = "Include"
      values   = [var.https_endpoint]
    }
  }

  dynamic "action" {
    for_each = var.application_insights_action_group_ids

    content {
      action_group_id = action.value
    }
  }

  depends_on = [
    helm_release.helm_this[0]
  ]
}
