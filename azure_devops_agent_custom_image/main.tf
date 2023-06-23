resource "azurerm_shared_image_gallery" "image_gallery" {
  count               = var.image_type == "shared" ? 1 : 0
  name                = "azdo_agent_images"
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = "Shared azure devops agent images"

  tags = var.tags
}


resource "azurerm_shared_image" "shared_image_placeholder" {
  count               = var.image_type == "shared" ? 1 : 0
  gallery_name        = azurerm_shared_image_gallery.image_gallery[count.index].name
  location            = var.location
  name                = var.image_name
  os_type             = "Linux"
  resource_group_name = var.resource_group_name

  identifier {
    offer     = var.base_image_offer
    publisher = var.base_image_publisher
    sku       = var.base_image_sku
  }

  hyper_v_generation = "V2"

  tags = var.tags
}


locals {
  # name of the image for 'managed' image_type
  target_image_name = "${var.image_name}-${var.image_version}"
  target_image_id   = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Compute/images/${local.target_image_name}"

  shared_resource_group_name = var.image_type == "shared" ? var.resource_group_name : null
  shared_gallery_name        = var.image_type == "shared" ? azurerm_shared_image_gallery.image_gallery[0].name : null
}


resource "null_resource" "build_packer_image" {

  triggers = {
    subscription         = var.subscription_id
    rg_name              = var.image_type == "shared" ? local.shared_resource_group_name : var.resource_group_name
    shared_gallery_name  = local.shared_gallery_name
    subscription         = var.subscription_id
    base_image_publisher = var.base_image_publisher
    base_image_offer     = var.base_image_offer
    base_image_sku       = var.base_image_sku
    base_image_version   = var.base_image_version
    vm_sku               = var.vm_sku
    image_name           = var.image_name
    image_version        = var.image_version
    location             = var.location
    image_type           = var.image_type
    replication_region   = var.replication_region

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
    -var "target_resource_group_name=${var.resource_group_name}" \
    -var "target_image_name=${local.target_image_name}" \
    -var "base_image_publisher=${var.base_image_publisher}" \
    -var "base_image_offer=${var.base_image_offer}" \
    -var "base_image_sku=${var.base_image_sku}" \
    -var "base_image_version=${var.base_image_version}" \
    -var "vm_sku=${var.vm_sku}" \
    -var "location=${var.location}" \
    -var "image_name=${var.image_name}" \
    -var "image_version=${var.image_version}" \
    -var "shared_resource_group_name=${local.shared_resource_group_name}" \
    -var "shared_gallery_name=${local.shared_gallery_name}" \
    -var "replication_region=${var.replication_region}" \
    .
    EOT
  }

}
