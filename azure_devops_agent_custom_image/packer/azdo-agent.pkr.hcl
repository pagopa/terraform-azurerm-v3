packer {
  required_plugins {
    azure = {
      version = ">= 1.4.2"
      source  = "github.com/hashicorp/azure"
    }
  }
}

source "azure-arm" "ubuntu" {
  #use_interactive_auth              = true
  subscription_id                   = var.subscription
  client_id                         = var.client_id
  client_secret                     = var.client_secret
  os_type                           = "Linux"
  image_publisher                   = var.base_image_publisher
  image_offer                       = var.base_image_offer
  image_sku                         = var.base_image_sku
  vm_size                           = var.vm_sku

  managed_image_name                = "${var.target_image_name}"
  managed_image_resource_group_name = var.target_resource_group_name

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
