resource "null_resource" "this" {
  # needs az cli > 2.0.81
  # see https://github.com/Azure/azure-cli/issues/12152

  triggers = {
    name                = var.name
    resource_group_name = var.resource_group_name
    subscription        = var.subscription
    config_json         = "${sha1(file("${path.module}/script-config.json"))}"
  }

  provisioner "local-exec" {
    command = <<EOT
      # az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID && \
      az account set -s ${var.subscription} && \
      az vmss create \
        --admin-username azureuser \
        --name ${var.name} \
        --resource-group ${var.resource_group_name} \
        --image ${var.image} \
        --vm-sku ${var.vm_sku} \
        --storage-sku ${var.storage_sku} \
        --authentication-type ${var.authentication_type} \
        --generate-ssh-keys \
        --instance-count 2 \
        --disable-overprovision \
        --upgrade-policy-mode manual \
        --single-placement-group false \
        --platform-fault-domain-count 1 \
        --load-balancer "" \
        --subnet ${var.subnet_id} && \
      az vmss extension set \
        --vmss-name ${var.name} \
        --resource-group ${var.resource_group_name} \
        --name CustomScript \
        --version 2.0 \
        --publisher Microsoft.Azure.Extensions \
        --extension-instance-name install_requirements \
        --settings "${path.module}/script-config.json"
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      # az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID && \
      az account set -s ${self.triggers.subscription} && \
      az vmss delete \
        --name ${self.triggers.name} \
        --resource-group ${self.triggers.resource_group_name}
    EOT
  }
}
