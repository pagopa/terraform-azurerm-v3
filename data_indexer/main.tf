locals {
  allowed_ips     = [for ip in var.allowed_ips : { ip_address = ip, virtual_network_subnet_id = null }]
  allowed_subnets = [for s in var.allowed_subnets : { ip_address = null, virtual_network_subnet_id = s }]
  ip_restrictions = concat(local.allowed_subnets, local.allowed_ips)
}

resource "azurerm_service_plan" "this" {
  count = var.plan_type == "internal" ? 1 : 0

  name                = var.plan_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = var.sku_name
  os_type  = "Linux"

  maximum_elastic_worker_count = var.plan_maximum_elastic_worker_count
  per_site_scaling_enabled     = var.plan_per_site_scaling

  tags = var.tags
}

resource "azurerm_subnet" "this" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.address_prefixes

  dynamic "delegation" {
    for_each = var.delegation == null ? [] : ["delegation"]
    content {
      name = var.delegation.name

      service_delegation {
        name    = var.delegation.service_delegation.name
        actions = var.delegation.service_delegation.actions
      }
    }
  }

  service_endpoints = var.service_endpoints

  private_link_service_network_policies_enabled = var.private_link_service_network_policies_enabled
  private_endpoint_network_policies_enabled     = var.private_endpoint_network_policies_enabled
}

resource "azurerm_linux_web_app" "cdc" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  service_plan_id = azurerm_service_plan.this[0].id
  https_only      = var.https_only
  #tfsec:ignore:azure-appservice-require-client-cert
  client_certificate_enabled = var.client_cert_enabled
  client_affinity_enabled    = var.client_affinity_enabled

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
    always_on         = var.always_on
    use_32_bit_worker = var.use_32_bit_worker_process
    application_stack {
      docker_image_name     = "${var.cdc_docker_image}:${var.cdc_docker_image_tag}"
      docker_registry_url = var.docker_registry_url
      node_version        = var.node_version
    }
    app_command_line       = var.app_command_line
    minimum_tls_version    = "1.2"
    ftps_state             = var.ftps_state
    vnet_route_all_enabled = var.subnet_id == null ? false : true

    health_check_path                 = var.health_check_path != null ? var.health_check_path : null
    health_check_eviction_time_in_min = var.health_check_path != null ? var.health_check_maxpingfailures : null

    http2_enabled = true

    dynamic "ip_restriction" {
      for_each = var.allowed_subnets
      iterator = subnet

      content {
        ip_address                = null
        virtual_network_subnet_id = subnet.value
        name                      = "rule"
      }
    }

    dynamic "ip_restriction" {
      for_each = local.ip_restrictions
      iterator = ip

      content {
        ip_address                = ip.value.ip_address
        virtual_network_subnet_id = ip.value.virtual_network_subnet_id
        name                      = "rule"
      }
    }

  }

  # Managed identity
  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings["DOCKER_CUSTOM_IMAGE_NAME"],
      virtual_network_subnet_id,
      app_settings["WEBSITE_HEALTHCHECK_MAXPINGFAILURES"],
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"]
    ]
  }

  dynamic "sticky_settings" {
    for_each = length(var.sticky_settings) == 0 ? [] : [1]
    content {
      app_setting_names = var.sticky_settings
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_autoscale_setting" "appservice_cdc" {
  name                = format("%s-autoscale", azurerm_linux_web_app.cdc[0].name)
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_web_app.cdc[0].plan_id

  profile {
    name = "default"

    capacity {
      default = var.cdc_autoscale_default
      minimum = var.cdc_autoscale_minimum
      maximum = var.cdc_autoscale_maximum
    }

    # Increase rules

    rule {
      metric_trigger {
        metric_name              = "CpuPercentage"
        metric_resource_id       = azurerm_linux_web_app.cdc[0].plan_id
        metric_namespace         = "microsoft.web/serverfarms"
        time_grain               = "PT1M"
        statistic                = "Average"
        time_window              = "PT5M"
        time_aggregation         = "Average"
        operator                 = "GreaterThan"
        threshold                = 60
        divide_by_instance_count = false
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "2"
        cooldown  = "PT5M"
      }
    }

    # Decrease rules

    rule {
      metric_trigger {
        metric_name              = "CpuPercentage"
        metric_resource_id       = azurerm_linux_web_app.cdc[0].plan_id
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
        cooldown  = "PT1H"
      }
    }
  }
}

resource "azurerm_linux_web_app" "data_ti" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  service_plan_id = azurerm_service_plan.this[0].id
  https_only      = var.https_only
  #tfsec:ignore:azure-appservice-require-client-cert
  client_certificate_enabled = var.client_cert_enabled
  client_affinity_enabled    = var.client_affinity_enabled

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
    always_on         = var.always_on
    use_32_bit_worker = var.use_32_bit_worker_process
    application_stack {
      docker_image_name   = "${var.data_ti_docker_image}:${var.data_ti_docker_image_tag}"
      docker_registry_url = var.docker_registry_url
      node_version        = var.node_version
    }
    app_command_line       = var.app_command_line
    minimum_tls_version    = "1.2"
    ftps_state             = var.ftps_state
    vnet_route_all_enabled = true

    health_check_path                 = var.health_check_path != null ? var.health_check_path : null
    health_check_eviction_time_in_min = var.health_check_path != null ? var.health_check_maxpingfailures : null

    http2_enabled = true

    dynamic "ip_restriction" {
      for_each = var.allowed_subnets
      iterator = subnet

      content {
        ip_address                = null
        virtual_network_subnet_id = subnet.value
        name                      = "rule"
      }
    }

    dynamic "ip_restriction" {
      for_each = local.ip_restrictions
      iterator = ip

      content {
        ip_address                = ip.value.ip_address
        virtual_network_subnet_id = ip.value.virtual_network_subnet_id
        name                      = "rule"
      }
    }

  }

  # Managed identity
  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings["DOCKER_CUSTOM_IMAGE_NAME"],
      virtual_network_subnet_id,
      app_settings["WEBSITE_HEALTHCHECK_MAXPINGFAILURES"],
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"]
    ]
  }

  dynamic "sticky_settings" {
    for_each = length(var.sticky_settings) == 0 ? [] : [1]
    content {
      app_setting_names = var.sticky_settings
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_autoscale_setting" "appservice_data_ti" {
  name                = format("%s-autoscale", azurerm_linux_web_app.data_ti[0].name)
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_web_app.data_ti[0].plan_id

  profile {
    name = "default"

    capacity {
      default = var.data_ti_autoscale_default
      minimum = var.data_ti_autoscale_minimum
      maximum = var.data_ti_autoscale_maximum
    }

    # Increase rules

    rule {
      metric_trigger {
        metric_name              = "CpuPercentage"
        metric_resource_id       = azurerm_linux_web_app.data_ti[0].plan_id
        metric_namespace         = "microsoft.web/serverfarms"
        time_grain               = "PT1M"
        statistic                = "Average"
        time_window              = "PT5M"
        time_aggregation         = "Average"
        operator                 = "GreaterThan"
        threshold                = 60
        divide_by_instance_count = false
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "2"
        cooldown  = "PT5M"
      }
    }

    # Decrease rules

    rule {
      metric_trigger {
        metric_name              = "CpuPercentage"
        metric_resource_id       = azurerm_linux_web_app.data_ti[0].plan_id
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
        cooldown  = "PT1H"
      }
    }
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "app_service_virtual_network_swift_connection" {
  count = var.vnet_integration ? 1 : 0

  app_service_id = azurerm_linux_web_app.this.id
  subnet_id      = azurerm_subnet.this[0].id
}
