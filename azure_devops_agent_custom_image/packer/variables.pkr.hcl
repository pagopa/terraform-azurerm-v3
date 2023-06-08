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

variable "shared_gallery_name"{
  type = string
  description = "Destination Gallery Name"
}

variable "image_name" {
  type = string
  description = "Destination Image Name"
}

variable "image_version"{
  type = string
  description = "Destination Image Version"
}


