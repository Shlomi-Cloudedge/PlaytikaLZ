terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.104.2"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-storage-mgmt-prod-we-001"
    storage_account_name = "stpttfstateswe001"
    container_name       = "azure-tfstates"
    subscription_id      = "d2b9ffa4-5f45-4b08-9429-6d18e4767db7"
    key                  = "azure_policies.tfstate"
  }
}

provider "azurerm" {
  features {}
}