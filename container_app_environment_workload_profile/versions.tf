# terraform {
#   required_version = ">= 1.3.0"

#   required_providers {
#     azapi = {
#       source  = "azure/azapi"
#       version = "<= 1.12.1"
#     }
#   }
# }

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.85.0, <= 3.97.0"
    }
  }
}
