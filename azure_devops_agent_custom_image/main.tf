locals {
  target_image_name = "${var.image_name}-${var.image_version}"
  target_image_id   = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Compute/images/${local.target_image_name}"
}


resource "azurerm_resource_group" "image_resource_group" {
  name     = "azdo-rg"
  location = var.location

  tags = var.tags
}

resource "azurerm_shared_image_gallery" "image_gallery" {
  name                = "azdo_agent_images"
  resource_group_name = azurerm_resource_group.image_resource_group.name
  location            = azurerm_resource_group.image_resource_group.location
  description         = "Shared images and things."

  tags = var.tags
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
  }

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
    packer init . && \
    packer build \
    -var "subscription=${var.subscription_id}" \
    -var "target_resource_group_name=${azurerm_resource_group.image_resource_group.name}" \
    -var "base_image_publisher=${var.base_image_publisher}" \
    -var "base_image_offer=${var.base_image_offer}" \
    -var "base_image_sku=${var.base_image_sku}" \
    -var "base_image_version=${var.base_image_version}" \
    -var "vm_sku=${var.vm_sku}" \
    -var "target_image_name=${local.target_image_name}" \
    -var "location=${var.location}" \
    -var "shared_gallery_name=${var.shared_gallery_name}" \
    -var "image_name=${var.image_name}" \
    -var "image_version=${var.image_version}" \
    .
    EOT
  }

}
