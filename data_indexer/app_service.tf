resource "azurerm_service_plan" "this" {
  name                = var.plan_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = var.sku_name
  os_type  = "Linux"

  maximum_elastic_worker_count = var.plan_maximum_elastic_worker_count
  per_site_scaling_enabled     = var.plan_per_site_scaling

  tags = var.tags
}

# CDC App Service ################################################################

resource "azurerm_linux_web_app" "cdc" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  service_plan_id = azurerm_service_plan.this.id
  https_only      = true
  #tfsec:ignore:azure-appservice-require-client-cert
  client_certificate_enabled = false
  client_affinity_enabled    = false

  # https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings
  app_settings = merge(
    {
      # https://docs.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16
      WEBSITE_DNS_SERVER = "168.63.129.16"
      # https://docs.microsoft.com/en-us/azure/azure-monitor/app/sampling
      APPINSIGHTS_SAMPLING_PERCENTAGE = 5
    },
    var.app_settings,
  )
  site_config {
    always_on         = true
    use_32_bit_worker = false
    application_stack {
      docker_image_name     = "${var.cdc_docker_image}:${var.cdc_docker_image_tag}"
      docker_registry_url = var.docker_registry_url
    }
    
    minimum_tls_version    = "1.2"
    ftps_state             = "Disabled"
    vnet_route_all_enabled = true

    health_check_path                 = "/info"
    health_check_eviction_time_in_min = 5
    http2_enabled = true
  }

  # Managed identity
  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"]
    ]
  }

  tags = var.tags
}

resource "azurerm_app_service_virtual_network_swift_connection" "cdc" {
  app_service_id = azurerm_linux_web_app.cdc.id
  subnet_id      = azurerm_subnet.this.id
}

resource "azurerm_role_assignment" "evh_sender" {
  for_each = data.azurerm_eventhub.evh
  scope                = each.value.id
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id         = azurerm_linux_web_app.cdc.id
}

################################################################################################

# Data Transformer App Service #################################################################
resource "azurerm_linux_web_app" "data_ti" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  service_plan_id = azurerm_service_plan.this.id
  https_only      = true
  #tfsec:ignore:azure-appservice-require-client-cert
  client_certificate_enabled = false
  client_affinity_enabled    = false

  # https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings
  app_settings = merge(
    {
      # https://docs.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16
      WEBSITE_DNS_SERVER = "168.63.129.16"
      # https://docs.microsoft.com/en-us/azure/azure-monitor/app/sampling
      APPINSIGHTS_SAMPLING_PERCENTAGE = 5
    },
    var.app_settings,
  )
  site_config {
    always_on         = true
    use_32_bit_worker = false
    application_stack {
      docker_image_name   = "${var.data_ti_docker_image}:${var.data_ti_docker_image_tag}"
      docker_registry_url = var.docker_registry_url
    }

    minimum_tls_version    = "1.2"
    ftps_state             = "Disabled"
    vnet_route_all_enabled = true

    health_check_path                 = "/info"
    health_check_eviction_time_in_min = 5
    http2_enabled = true

  }

  # Managed identity
  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"]
    ]
  }

  tags = var.tags
}

resource "azurerm_app_service_virtual_network_swift_connection" "data_ti" {
  app_service_id = azurerm_linux_web_app.data_ti.id
  subnet_id      = azurerm_subnet.this.id
}

resource "azurerm_role_assignment" "evh_listener" {
  for_each = data.azurerm_eventhub.evh
  scope                = each.value.id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = azurerm_linux_web_app.data_ti.id
}

# Plan Autoscale settings #######################################################

resource "azurerm_monitor_autoscale_setting" "appservice_plan" {
  name                = format("%s-autoscale", azurerm_service_plan.this.name)
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_service_plan.this.id

  profile {
    name = "default"

    capacity {
      default = var.autoscale_default
      minimum = var.autoscale_minimum
      maximum = var.autoscale_maximum
    }

    # Increase rules

    rule {
      metric_trigger {
        metric_name              = "CpuPercentage"
        metric_resource_id       = azurerm_service_plan.this.id
        metric_namespace         = "microsoft.web/serverfarms"
        time_grain               = "PT1M"
        statistic                = "Average"
        time_window              = "PT5M"
        time_aggregation         = "Average"
        operator                 = "GreaterThan"
        threshold                = 70
        divide_by_instance_count = false
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    # Decrease rules

    rule {
      metric_trigger {
        metric_name              = "CpuPercentage"
        metric_resource_id       = azurerm_service_plan.this.id
        metric_namespace         = "microsoft.web/serverfarms"
        time_grain               = "PT1M"
        statistic                = "Average"
        time_window              = "PT5M"
        time_aggregation         = "Average"
        operator                 = "LessThan"
        threshold                = 30
        divide_by_instance_count = false
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT20M"
      }
    }
  }
}