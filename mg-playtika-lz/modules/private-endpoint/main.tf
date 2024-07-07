terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

##################################################
# PRIVATE ENDPOINT
##################################################
resource "azurerm_private_endpoint" "pe" {
  for_each            = { for idx, pe in var.private_endpoint : idx => pe }
  name                = "pe-${each.value.resource_name}"
  resource_group_name = var.rg
  location            = var.location
  tags                = var.tags 
  subnet_id           = var.spoke_snet_id
  custom_network_interface_name = "nic-${each.value.resource_name}"

  private_service_connection {
    name                           = "pe-connection-${each.value.resource_name}"
    private_connection_resource_id = each.value.resource_id
    is_manual_connection           = false
    subresource_names              = each.value.subresource_names
  }

  private_dns_zone_group {
    name                 = "pe-dns-zone-group-${each.value.resource_name}"
    private_dns_zone_ids = [each.value.dns_zone_id]
  }

  lifecycle {
    ignore_changes = [ tags["auto_creation_date"] ]
  }
}