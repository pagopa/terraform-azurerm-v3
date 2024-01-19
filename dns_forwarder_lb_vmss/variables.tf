variable "name" {
  type        = string
  description = "(Required) The name of the Virtual Machine Scale Set, Load Balancer. Changing this forces a new resource to be created."
}

variable "location" {
  type        = string
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the Resource Group in which the resources should be exist."
}

variable "virtual_network_name" {
  type        = string
  description = "(Required) The name of the virtual network in which the resources (Vmss, LB) are located."
}

variable "subnet_vmss_id" {
  type        = string
  description = "(Optional) The subnet id of virtual machine scale set."
  default     = null
}

variable "subnet_lb_id" {
  type        = string
  description = "(Optional) The subnet id of load balancer."
  default     = null
}

variable "address_prefixes_vmss" {
  type        = string
  description = "(Optional) The address prefixes to use for the virtual machine scale set subnet."
  default     = "10.1.200.9/29"
}

variable "address_prefixes_lb" {
  type        = string
  description = "(Optional) The address prefixes to use for load balancer subnet."
  default     = "10.1.200.0/29"
}

variable "static_address_lb" {
  type        = string
  description = "(Optional) The static address of load balancer."
  default     = null
}

variable "subscription_id" {
  type        = string
  description = "(Required) Azure subscription id"
}

variable "tenant_id" {
  type        = string
  description = "(Required) The Azure AD tenant ID that should be used for authenticating requests to the key vault."
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
  description = "(Required) Type of authentication to use with the VM. Defaults to password for Windows and SSH public key for Linux. all enables both ssh and password authentication."
  default     = "SSH"
  validation {
    condition = (
      var.authentication_type == "SSH" ||
      var.authentication_type == "PASSWORD" ||
      var.authentication_type == "ALL"
    )
    error_message = "Error: authentication_type can be SSH, PASSWORD or ALL."
  }
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
