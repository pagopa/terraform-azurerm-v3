locals {
  template_content = templatefile("${path.module}/template.json", {
    location                          = var.location
    name                              = var.name
    sku_name = var.sku_name
    vnet_internal = var.vnet_internal
    subnet_id = var.subnet_id
    outbound_type = var.outbound_type
    log_destination = var.log_destination
    log_analytics_customer_id = var.log_analytics_customer_id
    log_analytics_shared_key = var.log_analytics_shared_key
    zone_redundant = var.zone_redundant
  })
}

resource "azurerm_resource_group_template_deployment" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name

  template_content = local.template_content

  deployment_mode = "Incremental"

  tags = var.tags
}
