variable "location" {
  type        = string
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "subscription_id" {
  type        = string
  description = "(Required) Azure subscription id"
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the Resource Group in which the custom image will be created"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#source_image_reference
variable "base_image_publisher" {
  type        = string
  default     = "Canonical"
  description = "(Optional) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#source_image_reference"
}

variable "image_name" {
  type        = string
  description = "(Required) name assigned to the generated image. Note that the pair <image_name, image_version> must be unique and not already existing"
}

variable "image_version" {
  type        = string
  description = "(Required) Version assigned to the generated image. Note that the pair <image_name, image_version> must be unique and not already existing"
}

variable "base_image_offer" {
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
  description = "(Optional) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#source_image_reference"
}
variable "base_image_sku" {
  type        = string
  default     = "22_04-lts-gen2"
  description = "(Optional) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#source_image_reference"
}

variable "base_image_version" {
  type        = string
  default     = "latest"
  description = "(Optional) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#source_image_reference"
}

variable "vm_sku" {
  type        = string
  description = "(Optional) Size of VMs in the scale set. Default to Standard_B1s. See https://azure.microsoft.com/pricing/details/virtual-machines/ for size info."
  default     = "Standard_B2ms"
}

variable "prefix" {
  type        = string
  description = "(Required) prefix used in resource creation"
}

variable "build_rg_name" {
  type        = string
  description = "(Optional) Packer build temporary resource group name"
  default     = "tmp-packer-azdo-image-build"
}

#
# Custom VNET
#
variable "use_external_vnet" {
  type        = bool
  description = "Enable the use of a custom vnet"
  default     = false
}

variable "build_vnet_name" {
  type        = string
  description = "(Optional) Packer build vnet name"
  default     = null
}

variable "build_subnet_name" {
  type        = string
  description = "(Optional) Packer build subnet name"
  default     = null
}

variable "build_vnet_rg_name" {
  type        = string
  description = "(Optional) Packer build vnet rg name"
  default     = null
}
