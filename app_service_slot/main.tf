resource "azurerm_linux_web_app_slot" "this" {
  name = var.name

  app_service_id                = var.app_service_id
  https_only                    = var.https_only
  public_network_access_enabled = var.public_network_access_enabled
  client_affinity_enabled       = var.client_affinity_enabled
  client_certificate_enabled    = var.client_certificate_enabled

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
      for_each = var.allowed_ips
      iterator = ip

      content {
        ip_address                = ip.value
        virtual_network_subnet_id = null
        name                      = "rule"
      }
    }

    dynamic "ip_restriction" {
      for_each = var.allowed_service_tags
      iterator = st

      content {
        service_tag = st.value
        name        = "rule"
      }
    }

    dynamic "auto_heal_setting" {
      for_each = var.auto_heal_enabled ? [1] : []
      content {
        action {
          action_type                    = "Recycle"
          minimum_process_execution_time = var.auto_heal_settings.startup_time
        }
        trigger {
          slow_request {
            count      = var.auto_heal_settings.slow_requests_count
            interval   = var.auto_heal_settings.slow_requests_interval
            time_taken = var.auto_heal_settings.slow_requests_time
          }
        }
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      app_settings["DOCKER_CUSTOM_IMAGE_NAME"],
      virtual_network_subnet_id,
      app_settings["WEBSITE_HEALTHCHECK_MAXPINGFAILURES"],
    ]
  }
}

resource "azurerm_app_service_slot_virtual_network_swift_connection" "app_service_virtual_network_swift_connection" {
  count = var.vnet_integration ? 1 : 0

  slot_name      = azurerm_linux_web_app_slot.this.name
  app_service_id = var.app_service_id
  subnet_id      = var.subnet_id
}
