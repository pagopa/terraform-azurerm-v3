locals {
  target_image_name = "${var.image_name}-${var.image_version}"
  target_image_id   = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Compute/images/${local.target_image_name}"
}

data "azuread_client_config" "current" {}

data "azurerm_resource_group" "target_resource_group" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "build_vnet" {
  count               = var.use_external_vnet ? 1 : 0
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



resource "azurerm_resource_group" "build_rg" {
  location = var.location
  name     = "${var.build_rg_name}-${random_id.rg_randomizer.hex}"
}


resource "null_resource" "build_packer_image" {

  triggers = {
    target_resource_group_name = var.resource_group_name
    base_image_publisher       = var.base_image_publisher
    base_image_offer           = var.base_image_offer
    base_image_sku             = var.base_image_sku
    base_image_version         = var.base_image_version
    vm_sku                     = var.vm_sku
    target_image_name          = local.target_image_name
    location                   = var.location
    use_external_vnet          = var.use_external_vnet
  }

  depends_on = [
    azurerm_resource_group.build_rg,
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
      pwd && \
      packer build \
      -var "target_resource_group_name=${var.resource_group_name}" \
      -var "base_image_publisher=${var.base_image_publisher}" \
      -var "base_image_offer=${var.base_image_offer}" \
      -var "base_image_sku=${var.base_image_sku}" \
      -var "base_image_version=${var.base_image_version}" \
      -var "vm_sku=${var.vm_sku}" \
      -var "target_image_name=${local.target_image_name}" \
      -var "location=${var.location}" \
      -var "build_rg_name=${azurerm_resource_group.build_rg.name}" \
      %{ if var.use_external_vnet }
      -var "build_vnet_name=${var.build_vnet_name}" \
      -var "build_vnet_subnet_name=${var.build_subnet_name}" \
      -var "build_vnet_rg_name=${var.build_vnet_rg_name}" \
      %{ endif }
      azdo-agent.pkr.hcl
    EOT
  }

}
