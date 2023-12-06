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

resource "azurerm_linux_web_app" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  service_plan_id = var.plan_type == "internal" ? azurerm_service_plan.this[0].id : var.plan_id
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
      docker_image     = var.docker_image
      docker_image_tag = var.docker_image_tag

      dotnet_version      = var.dotnet_version
      python_version      = var.python_version
      go_version          = var.go_version
      java_server         = var.java_server
      java_server_version = var.java_server_version
      java_version        = var.java_version
      node_version        = var.node_version
      php_version         = var.php_version
      ruby_version        = var.ruby_version
    }
    app_command_line       = var.app_command_line
    minimum_tls_version    = "1.2"
    ftps_state             = var.ftps_state
    vnet_route_all_enabled = var.subnet_id == null ? false : true

    health_check_path = var.health_check_path != null ? var.health_check_path : null

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

resource "azurerm_app_service_virtual_network_swift_connection" "app_service_virtual_network_swift_connection" {
  count = var.vnet_integration ? 1 : 0

  app_service_id = azurerm_linux_web_app.this.id
  subnet_id      = var.subnet_id
}
