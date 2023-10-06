output "standard_hdd" {
  value       = kubernetes_storage_class_v1.standard_hdd.metadata[0].name
  description = "Standard HDD storage class name"
}

output "azurefile_zrs" {
  value       = kubernetes_storage_class_v1.azurefile_zrs.metadata[0].name
  description = "Azurefile with ZRS storage class name"
}

output "azurefile_csi_zrs" {
  value       = kubernetes_storage_class_v1.azurefile_csi_zrs.metadata[0].name
  description = "Azurefile CSI with ZRS storage class name"
}

output "azurefile_csi_premium_zrs" {
  value       = kubernetes_storage_class_v1.azurefile_csi_premium_zrs.metadata[0].name
  description = "Azurefile CSI premium disk with ZRS storage class name"
}

output "azurefile_premium_zrs" {
  value       = kubernetes_storage_class_v1.azurefile_premium_zrs.metadata[0].name
  description = "Azurefile premium with ZRS storage class name"
}

output "default_zrs" {
  value       = kubernetes_storage_class_v1.default_zrs.metadata[0].name
  description = "Default with ZRS storage class name"
}

output "managed_zrs" {
  value       = kubernetes_storage_class_v1.managed_zrs.metadata[0].name
  description = "Managed with ZRS storage class name"
}

output "managed_csi_zrs" {
  value       = kubernetes_storage_class_v1.managed_csi_zrs.metadata[0].name
  description = "Managed CSI with ZRS storage class name"
}

output "managed_csi_premium_zrs" {
  value       = kubernetes_storage_class_v1.managed_csi_premium_zrs.metadata[0].name
  description = "Managed CSI  premium with ZRS storage class name"
}





