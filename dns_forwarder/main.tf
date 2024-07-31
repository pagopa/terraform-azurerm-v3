resource "azurerm_container_group" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = "Private"
  subnet_ids          = [var.subnet_id]
  os_type             = "Linux"

  container {
    name = "dns-forwarder"
    # from https://hub.docker.com/r/coredns/coredns
    image  = "coredns/coredns:1.10.1@sha256:be7652ce0b43b1339f3d14d9b14af9f588578011092c1f7893bd55432d83a378"
    cpu    = "0.5"
    memory = "0.5"

    commands = ["/coredns", "-conf", "/app/conf/Corefile"]

    ports {
      port     = 53
      protocol = "UDP"
    }

    volume {
      mount_path = "/app/conf"
      name       = "dns-forwarder-conf"
      read_only  = true
      secret = {
        Corefile = base64encode(data.local_file.corefile.content)
      }
    }

  }

  tags = var.tags

  lifecycle {
    ignore_changes       = [container[0].volume[0].secret]
    replace_triggered_by = [null_resource.secret_trigger.id]
  }
}

data "local_file" "corefile" {
  filename = format("%s/Corefile", path.module)
}

resource "null_resource" "secret_trigger" {
  triggers = {
    trigger = base64encode(data.local_file.corefile.content)
  }
}