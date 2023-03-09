locals {
  app_settings = {
    # Monitoring
    APPINSIGHTS_INSTRUMENTATIONKEY                  = azurerm_application_insights.ai.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING           = "InstrumentationKey=${azurerm_application_insights.ai.instrumentation_key}"
    APPINSIGHTS_PROFILERFEATURE_VERSION             = "1.0.0"
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION             = "1.0.0"
    APPLICATIONINSIGHTS_CONFIGURATION_CONTENT       = ""
    ApplicationInsightsAgent_EXTENSION_VERSION      = "~3"
    DiagnosticServices_EXTENSION_VERSION            = "~3"
    InstrumentationEngine_EXTENSION_VERSION         = "disabled"
    SnapshotDebugger_EXTENSION_VERSION              = "disabled"
    XDT_MicrosoftApplicationInsights_BaseExtensions = "disabled"
    XDT_MicrosoftApplicationInsights_Mode           = "recommended"
    XDT_MicrosoftApplicationInsights_PreemptSdk     = "disabled"
    WEBSITE_HEALTHCHECK_MAXPINGFAILURES             = 10
    TIMEOUT_DELAY                                   = 300
    # Integration with private DNS (see more: https://docs.microsoft.com/en-us/answers/questions/85359/azure-app-service-unable-to-resolve-hostname-of-vi.html)
    WEBSITE_DNS_SERVER = "168.63.129.16"
    # Spring Environment

    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    WEBSITES_PORT                       = 8000
  }
}

resource "random_id" "function_id" {
  byte_length = 3
}

resource "azurerm_container_registry" "reg" {
  name                = "${local.project}registry"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = false
}

resource "azurerm_application_insights" "ai" {
  name                = "${local.project}-ai"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  application_type    = "other"

  tags = var.tags
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.project}-rg"
  location = var.location

  tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.project}-vnet"
  address_space       = var.vnet_address_space
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  tags = var.tags
}

# Subnet to host the api config
resource "azurerm_subnet" "arm_subnet" {
  name                 = "${local.project}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_cidr

  delegation {
    name = "${local.project}-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_service_plan" "app_docker" {

  name                = "${local.project}-plan-app-service-docker"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  os_type  = "Linux"
  sku_name = "P1v3"

  tags = var.tags
}

module "web_app_service_docker" {
  source = "../../app_service"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  plan_type = "external"
  plan_id   = azurerm_service_plan.app_docker.id

  # App service plan
  name                = "${local.project}-app-service-docker"
  client_cert_enabled = false
  always_on           = false
  docker_image        = "${azurerm_container_registry.reg.login_server}/devopswebapppython"
  docker_image_tag    = "latest"

  health_check_path = "/status"
  sku_name          = "P1v3"

  app_settings = local.app_settings

  allowed_ips = []

  subnet_id = azurerm_subnet.arm_subnet.id

  allowed_subnets = [
    azurerm_subnet.arm_subnet.id,
  ]

  tags = var.tags
}

module "web_app_service_slot_docker" {
  source = "../"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  app_service_name = module.web_app_service_docker.name
  app_service_id   = module.web_app_service_docker.id

  # App service plan
  name                       = "${local.project}-app-service-slot-docker"
  client_certificate_enabled = false

  always_on        = false
  docker_image     = "${azurerm_container_registry.reg.login_server}/devopswebapppython"
  docker_image_tag = "latest"

  health_check_path = "/status"

  app_settings = local.app_settings

  allowed_ips = []

  subnet_id = azurerm_subnet.arm_subnet.id

  allowed_subnets = [
    azurerm_subnet.arm_subnet.id,
  ]

  tags = var.tags
}
