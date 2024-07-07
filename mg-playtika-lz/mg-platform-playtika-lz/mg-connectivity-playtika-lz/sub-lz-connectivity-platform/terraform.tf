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
    key                  = "sub-lz-connectivity-platform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.connectivity_subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.service_principal_client_id
  client_secret   = var.client_secret_service_principal
}