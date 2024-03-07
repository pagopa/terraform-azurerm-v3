data "azurerm_eventhub" "evh" {
    for_each = var.evh_config.topics
    
    name                = each.value
    resource_group_name = var.evh_config.resource_group_name
    namespace_name      = var.evh_config.name
}