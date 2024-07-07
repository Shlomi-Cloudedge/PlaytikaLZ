terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.104.2"
    }
  }
  backend "azurerm" {
    resource_group_name = "rg-storage-mgmt-prod-we-001"
    storage_account_name = "stpttfstateswe001"
    container_name = "azure-tfstates"
    subscription_id = "d2b9ffa4-5f45-4b08-9429-6d18e4767db7"
    key = "sub-lz-management-platform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "d2b9ffa4-5f45-4b08-9429-6d18e4767db7"
  tenant_id = "02f22272-3538-4a5f-ae4e-64cd13d9890e"
  client_id = "8133457b-4ddf-4360-aa6d-5c2a864d1e37"
  client_secret = var.client_secret_service_principal
}