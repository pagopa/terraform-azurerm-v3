variable "location" {
  type        = string
  default     = "northeurope"
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}


variable "subscription" {
  type        = string
  description = "(Required) Azure subscription"
}

variable "target_resource_group_name" {
  type        = string
  description = "(string) - Resource group under which the final artifact will be stored."
}


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#source_image_reference
variable "base_image_publisher" {
  type        = string
  default = "Canonical"
}
variable "base_image_offer" {
  type        = string
  default = "0001-com-ubuntu-server-jammy"
}
variable "base_image_sku" {
  type        = string
  default = "22_04-lts-gen2"
}
variable "base_image_version" {
  type        = string
  default = "latest"
}

variable "vm_sku" {
  type        = string
  description = "(Optional) Size of VMs in the scale set. Default to Standard_B1s. See https://azure.microsoft.com/pricing/details/virtual-machines/ for size info."
  default     = "Standard_B1s"
}

variable "target_image_name" {
  type        = string
  description = "(Required) name assigned to the generated image. Note that myust be unique and not already exist"
}


variable "client_id" {
  type        = string
  description = "(Required) Service principal client id"
}

variable "client_secret" {
  type        = string
  description = "(Required) service principal client secret"
}

variable "build_rg_name" {
  type        = string
  description = "(Required) temporary build resource group name"
}

variable "build_vnet_name" {
  type        = string
  description = "(Required) temporary build resource group name"
}
variable "build_vnet_subnet_name" {
  type        = string
  description = "(Required) temporary build resource group name"
}
variable "build_vnet_rg_name" {
  type        = string
  description = "(Required) temporary build resource group name"
}
