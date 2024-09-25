terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.0.0"
    }

   azuread = {
      source  = "hashicorp/azuread"
      version = "= 2.53.0"
    }
  }
}