locals {
  target_image_name = "${var.image_name}-${var.image_version}"
  target_image_id   = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Compute/images/${local.target_image_name}"
}

data "azuread_client_config" "current" {}

data "azurerm_resource_group" "target_resource_group" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "build_vnet" {
  count = !var.use_external_vnet ? 1 : 0
  name                = var.build_vnet_name
  resource_group_name = var.build_vnet_rg_name
}

#--------------- RESOURCES ------------------------

resource "random_id" "rg_randomizer" {
  keepers = {
    image_name    = var.image_name
    image_version = var.image_version
  }
  byte_length = 8
}

resource "azuread_application" "packer_application" {
  display_name = "${var.prefix}-packer-application"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_password" "velero_application_password" {
  application_object_id = azuread_application.packer_application.object_id
}

resource "azuread_service_principal" "packer_sp" {

  application_id = azuread_application.packer_application.application_id
  owners         = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "packer_principal_password" {
  service_principal_id = azuread_service_principal.packer_sp.object_id
}

resource "azurerm_role_assignment" "packer_sp_sub_reader_role" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.packer_sp.object_id
}

resource "azurerm_role_assignment" "packer_sp_rg_role" {
  scope                = data.azurerm_resource_group.target_resource_group.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.packer_sp.object_id
}

resource "azurerm_resource_group" "build_rg" {
  location = var.location
  name     = "${var.build_rg_name}-${random_id.rg_randomizer.hex}"
}

resource "azurerm_role_assignment" "packer_sp_build_rg_role" {
  scope                = azurerm_resource_group.build_rg.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.packer_sp.object_id
}

resource "azurerm_role_assignment" "packer_sp_build_vnet_role" {
  count = !var.use_external_vnet ? 1 : 0

  scope                = data.azurerm_virtual_network.build_vnet[0].id
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.packer_sp.object_id
}

resource "null_resource" "build_packer_image" {

  triggers = {
    subscription               = var.subscription_id
    target_resource_group_name = var.resource_group_name
    base_image_publisher       = var.base_image_publisher
    base_image_offer           = var.base_image_offer
    base_image_sku             = var.base_image_sku
    base_image_version         = var.base_image_version
    vm_sku                     = var.vm_sku
    target_image_name          = local.target_image_name
    location                   = var.location
    use_external_vnet = var.use_external_vnet
  }

  depends_on = [
    azurerm_role_assignment.packer_sp_build_rg_role,
    azurerm_resource_group.build_rg,
    azuread_application.packer_application
  ]

  # remove old packer cache
  provisioner "local-exec" {
    command = <<EOT
    rm -rf "$HOME/.azure/packer"
    EOT
  }

  # requires packer https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli
  provisioner "local-exec" {
    working_dir = "${path.module}/packer"
    command     = <<EOT
    {
      packer init .

      packer build \
      -var "subscription=${var.subscription_id}" \
      -var "target_resource_group_name=${var.resource_group_name}" \
      -var "base_image_publisher=${var.base_image_publisher}" \
      -var "base_image_offer=${var.base_image_offer}" \
      -var "base_image_sku=${var.base_image_sku}" \
      -var "base_image_version=${var.base_image_version}" \
      -var "vm_sku=${var.vm_sku}" \
      -var "target_image_name=${local.target_image_name}" \
      -var "location=${var.location}" \
      -var "client_id=${azuread_application.packer_application.application_id}" \
      -var "client_secret=${azuread_application_password.velero_application_password.value}" \
      -var "build_rg_name=${azurerm_resource_group.build_rg.name}" \
      ${var.use_external_vnet ? "-var 'build_vnet_name=${var.build_vnet_name}'" : "" } \
      ${var.use_external_vnet ? "-var 'build_vnet_subnet_name=${var.build_subnet_name}'" : "" } \
      ${var.use_external_vnet ? "-var 'build_vnet_rg_name=${var.build_vnet_rg_name}'" : "" } \
      .

    } >> /tmp/packer-azdo.log
    EOT
  }

}
