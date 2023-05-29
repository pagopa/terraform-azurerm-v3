terraform {
  required_version = ">= 1.3.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "<= 3.2.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.5.1, <= 2.7.1"
    }
  }
}
