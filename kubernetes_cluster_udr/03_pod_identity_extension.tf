resource "null_resource" "enable_pod_identity" {
  # needs az extension
  # see https://docs.microsoft.com/en-us/azure/aks/use-azure-ad-pod-identity#before-you-begin

  count = var.addon_azure_pod_identity_enabled ? 1 : 0

  triggers = {
    resource_group_name = var.resource_group_name
    cluster_name        = azurerm_kubernetes_cluster.this.name
  }

  provisioner "local-exec" {
    command = <<EOT
      if az extension list-available | grep aks-preview > /dev/null
      then
        az extension add --name aks-preview || true

        az aks update \
          --resource-group ${self.triggers.resource_group_name} \
          --name ${self.triggers.cluster_name} \
          --enable-pod-identity \
          --no-wait \
          --yes
      else
        echo "addon: aks-preview not avaible"
      fi
    EOT
  }

  # provisioner "local-exec" {
  #   when    = destroy
  #   command = <<EOT
  #     if az extension list-available | grep aks-preview > /dev/null
  #     then
  #       az aks update \
  #         -g ${self.triggers.resource_group_name} \
  #         -n ${self.triggers.cluster_name} \
  #         --disable-pod-identity \
  #         --no-wait \
  #         --yes
  #     else
  #       echo "addon: aks-preview not avaible"
  #     fi
  #   EOT
  # }

  depends_on = [
    azurerm_kubernetes_cluster.this
  ]
}

