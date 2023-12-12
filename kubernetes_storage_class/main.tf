#
# HDD
#
resource "kubernetes_storage_class_v1" "standard_hdd" {
  metadata {
    name = "standard-hdd"
  }
  storage_provisioner = "kubernetes.io/azure-disk"
  reclaim_policy      = "Delete"
  parameters = {
    storageAccountType = "Standard_LRS"
  }
}

#
# Azure Files
#
resource "kubernetes_storage_class_v1" "azurefile_zrs" {
  metadata {
    name = "azurefile-zrs"
  }
  allow_volume_expansion = true
  storage_provisioner    = "file.csi.azure.com"
  reclaim_policy         = "Delete"
  mount_options = [
    "mfsymlinks",
    "actimeo=30",
    "nosharesock"
  ]
  volume_binding_mode = "Immediate"
  parameters = {
    skuName = "Standard_ZRS"
  }
}

resource "kubernetes_storage_class_v1" "azurefile_csi_zrs" {
  metadata {
    name = "azurefile-csi-zrs"
  }
  allow_volume_expansion = true
  storage_provisioner    = "file.csi.azure.com"
  reclaim_policy         = "Delete"
  mount_options = [
    "mfsymlinks",
    "actimeo=30",
    "nosharesock"
  ]
  volume_binding_mode = "Immediate"
  parameters = {
    skuName = "Standard_ZRS"
  }
}


resource "kubernetes_storage_class_v1" "azurefile_csi_premium_zrs" {
  metadata {
    name = "azurefile-csi-premium-zrs"
  }
  allow_volume_expansion = true
  storage_provisioner    = "file.csi.azure.com"
  reclaim_policy         = "Delete"
  mount_options = [
    "mfsymlinks",
    "actimeo=30",
    "nosharesock"
  ]
  volume_binding_mode = "Immediate"
  parameters = {
    skuName = "Premium_ZRS"
  }
}

resource "kubernetes_storage_class_v1" "azurefile_premium_zrs" {
  metadata {
    name = "azurefile-premium-zrs"
  }
  allow_volume_expansion = true
  storage_provisioner    = "file.csi.azure.com"
  reclaim_policy         = "Delete"
  mount_options = [
    "mfsymlinks",
    "actimeo=30",
    "nosharesock"
  ]
  volume_binding_mode = "Immediate"
  parameters = {
    skuName = "Premium_ZRS"
  }
}

#
# Default
#
resource "kubernetes_storage_class_v1" "default_zrs" {
  metadata {
    name = "default-zrs"
  }
  allow_volume_expansion = true
  storage_provisioner    = "disk.csi.azure.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  parameters = {
    skuname = "StandardSSD_ZRS"
  }
}

#
# Managed
#
resource "kubernetes_storage_class_v1" "managed_zrs" {
  metadata {
    name = "managed-zrs"
  }
  allow_volume_expansion = true
  storage_provisioner    = "disk.csi.azure.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  parameters = {
    cachingmode        = "ReadOnly"
    kind               = "Managed"
    storageaccounttype = "StandardSSD_ZRS"
  }
}


resource "kubernetes_storage_class_v1" "managed_csi_zrs" {
  metadata {
    name = "managed-csi-zrs"
  }
  allow_volume_expansion = true
  storage_provisioner    = "disk.csi.azure.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  parameters = {
    skuName = "StandardSSD_ZRS"
  }
}

resource "kubernetes_storage_class_v1" "managed_csi_premium_zrs" {
  metadata {
    name = "managed-csi-premium-zrs"
  }
  allow_volume_expansion = true
  storage_provisioner    = "disk.csi.azure.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  parameters = {
    skuName = "Premium_ZRS"
  }
}





