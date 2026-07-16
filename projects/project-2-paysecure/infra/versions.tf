terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }

  # Configure the azurerm backend in the pipeline. Do not commit backend access keys.
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}
