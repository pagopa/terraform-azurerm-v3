variable "name" {
  type        = string
  description = "(Required) The name of the Virtual Machine Scale Set. Changing this forces a new resource to be created."
}

variable "location" {
  type        = string
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the Resource Group in which the resources should be exist."
}

variable "subscription_id" {
  type        = string
  description = "(Required) Azure subscription id"
}

variable "subnet_id" {
  type        = string
  description = "(Required) The subnet id of virtual machine scale set."
}

variable "source_image_name" {
  type        = string
  description = "(Required) The name of an Image which each Virtual Machine in this Scale Set should be based on. It must be stored in the same subscription & resource group of this resource"
}

variable "vm_sku" {
  type        = string
  description = "(Optional) Size of VMs in the scale set. Default to Standard_B1s. See https://azure.microsoft.com/pricing/details/virtual-machines/ for size info."
  default     = "Standard_B1s"
}

variable "admin_password" {
  type        = string
  description = "(Optional) The Password which should be used for the local-administrator on this Virtual Machine. Changing this forces a new resource to be created. will be stored in the raw state as plain-text"
  default     = null
}

variable "storage_sku" {
  type        = string
  description = "(Optional) The SKU of the storage account with which to persist VM. Use a singular sku that would be applied across all disks, or specify individual disks. Usage: [--storage-sku SKU | --storage-sku ID=SKU ID=SKU ID=SKU...], where each ID is os or a 0-indexed lun. Allowed values: Standard_LRS, Premium_LRS, StandardSSD_LRS, UltraSSD_LRS, Premium_ZRS, StandardSSD_ZRS."
  default     = "StandardSSD_LRS"
}

variable "encryption_set_id" {
  type        = string
  description = "(Optional) An existing encryption set"
  default     = null
}

variable "authentication_type" {
  type        = string
  description = "(Optional) Type of authentication to use with the VM. Defaults to password for Windows and SSH public key for Linux. all enables both ssh and password authentication."
  default     = null
}

variable "capacity_default_count" {
  type        = number
  description = "(Optional) The number of instances that are available for scaling if metrics are not available for evaluation. The default is only used if the current instance count is lower than the default. Valid values are between 0 and 1000"
  default     = 1
}

variable "capacity_maximum_count" {
  type        = number
  description = "(Optional) The maximum number of instances for this resource. Valid values are between 0 and 1000"
  default     = 1
}

variable "capacity_minimum_count" {
  type        = number
  description = "(Optional) The minimum number of instances for this resource. Valid values are between 0 and 1000"
  default     = 1
}

variable "tags" {
  description = "(Required) Tags of all resources."
  type        = map(any)
}
