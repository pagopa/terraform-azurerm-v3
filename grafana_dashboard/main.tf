provider "grafana" {
   alias = "cloud"

   url   = var.grafana_url 
   auth  = var.grafana_api_key 
}

locals {
allowed_resource_by_file=fileset("${path.module}/dashboard/*.json","*.json")
allowed_resource_type_replaced = [
        for item in local.allowed_resource_by_file:
                replace(item, "_", "/")
        ]
allowed_resource_type =  [
        for item in local.allowed_resource_type_replaced:
                trimsuffix(item,".json")
        ]


}

data "azurerm_resources" "sub_resources" {
  #for_each = toset(local.allowed_resource_type)
  type = ["Microsoft.DBforPostgreSQL/flexibleServers","Microsoft.Storage/storageAccounts"]

  required_tags = {
    grafana = "yes"
  }
}

locals {
dashboard_folder_map =  flatten([
    for rt in data.azurerm_resources.sub_resources : {
        name        = split("/",rt.type)[1]
    }
  ])

dashboard_resource_map = flatten([
    for rt in data.azurerm_resources.sub_resources : [
      for d in rt.resources : {
        type          = d.type
        name          = d.name
        rgroup        = split("/",d.id)[4]
      }
    ]
  ])

  
}

resource "grafana_folder" "domainsfolder" {
   provider = grafana.cloud
   for_each    = { for i in range(length(local.dashboard_folder_map)) : local.dashboard_folder_map[i].name => i }

   title = "${upper(var.prefix)}-${upper(local.dashboard_folder_map[each.value].name)}-dashboard"
}

resource "grafana_dashboard" "azure_monitor_storage_insights" {
  provider    = grafana.cloud
  for_each    = { for i in range(length(local.dashboard_resource_map)) : local.dashboard_resource_map[i].name => i }

  config_json = templatefile("${path.module}/dashboard/${replace(local.dashboard_resource_map[each.value].type,"/","_")}.json", { TITOLOTEST = "${format("%s",local.dashboard_resource_map[each.value].name)}"})
  folder = grafana_folder.domainsfolder["${split("/",local.dashboard_resource_map[each.value].type)[1]}"].id
  overwrite = true 
}