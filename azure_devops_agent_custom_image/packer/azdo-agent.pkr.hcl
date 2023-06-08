packer {
  required_plugins {
    azure = {
      version = ">= 1.4.2"
      source  = "github.com/hashicorp/azure"
    }
  }
}

source "azure-arm" "ubuntu" {
  use_interactive_auth              = true
  subscription_id                   = var.subscription

  os_type                           = "Linux"
  image_publisher                   = var.base_image_publisher
  image_offer                       = var.base_image_offer
  image_sku                         = var.base_image_sku
  vm_size                           = var.vm_sku

  managed_image_name                = var.target_image_name
  managed_image_resource_group_name = var.target_resource_group_name

  #https://developer.hashicorp.com/packer/plugins/builders/azure/arm#shared-image-gallery
  shared_image_gallery_destination {
    subscription = var.subscription
    resource_group = var.shared_resource_group_name
    gallery_name = var.shared_gallery_name
    image_name = var.image_name
    image_version = var.image_version
#    replication_regions ([]string) - Sig Destination Replication Regions
    storage_account_type= "Standard_LRS"
  }

  location                          = var.location
  ssh_username                      = "packer"
  ssh_password                      = "password"
  communicator                      = "ssh"
}

build {
  sources = ["azure-arm.ubuntu"]

  provisioner "file" {
    source = "./script-config.sh"
    destination = "/tmp/script-config.sh"
  }

  provisioner "shell" {
    inline = ["sudo /bin/bash /tmp/script-config.sh"]
  }
}
