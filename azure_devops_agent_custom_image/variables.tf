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

variable "force_replacement" {
  type        = bool
  description = "(Optional) Wheather if the image should be deleted and recreated even if already existing"
  default     = false
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
  default     = "Standard_B1s"
}

variable "tags" {
  type = map(any)
}
