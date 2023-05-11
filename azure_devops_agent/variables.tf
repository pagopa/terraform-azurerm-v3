variable "location" {
  type        = string
  default     = "westeurope"
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "name" {
  type        = string
  description = "(Required) The name of the Linux Virtual Machine Scale Set. Changing this forces a new resource to be created."
}

variable "subscription" {
  type        = string
  description = "(Required) Azure subscription"
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the Resource Group in which the Linux Virtual Machine Scale Set should be exist. Changing this forces a new resource to be created."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#source_image_reference
variable "image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  description = "(Optional) A source_image_reference block as defined below."
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

variable "vm_sku" {
  type        = string
  description = "(Optional) Size of VMs in the scale set. Default to Standard_B1s. See https://azure.microsoft.com/pricing/details/virtual-machines/ for size info."
  default     = "Standard_B1s"
}

variable "storage_sku" {
  type        = string
  description = "(Optional) The SKU of the storage account with which to persist VM. Use a singular sku that would be applied across all disks, or specify individual disks. Usage: [--storage-sku SKU | --storage-sku ID=SKU ID=SKU ID=SKU...], where each ID is os or a 0-indexed lun. Allowed values: Standard_LRS, Premium_LRS, StandardSSD_LRS, UltraSSD_LRS, Premium_ZRS, StandardSSD_ZRS."
  default     = "StandardSSD_LRS"
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

variable "subnet_id" {
  type        = string
  description = "(Required) An existing subnet ID"
  default     = null
}

variable "encryption_set_id" {
  type        = string
  description = "(Optional) An existing encryption set"
  default     = null
}

variable "admin_password" {
  type        = string
  description = "(Optional) The Password which should be used for the local-administrator on this Virtual Machine. Changing this forces a new resource to be created. will be stored in the raw state as plain-text"
  default     = null
}


variable "tags" {
  type = map(any)
}
