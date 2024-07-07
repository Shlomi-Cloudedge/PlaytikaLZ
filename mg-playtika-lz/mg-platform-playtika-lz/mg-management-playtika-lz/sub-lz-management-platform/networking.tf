resource "azurerm_resource_group" "netsec_rg" {
  name     = "${module.netsec_rg_naming.resource_group.name}-001"
  location = var.location
  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })
    lifecycle {
    ignore_changes = [ tags["auto_creation_date"] ]
  }
}


resource "azurerm_virtual_network" "mgmnt-vnet" {
  name                = "${module.netsec_rg_naming.virtual_network.name}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.netsec_rg.name
  address_space       = var.virtual_network_address_space

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })
    lifecycle {
    ignore_changes = [ tags["auto_creation_date"] ]
  }
}

resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.netsec_rg.name
  virtual_network_name = azurerm_virtual_network.mgmnt-vnet.name
  address_prefixes     = each.value.address_prefixes

  dynamic "delegation" {
    for_each = coalesce(each.value.delegations, []) # Use coalesce to handle null delegations
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

#Peering to Hub VNet
resource "azurerm_virtual_network_peering" "mgmt-to-hub" {
  name                      = "${azurerm_virtual_network.mgmnt-vnet.name}-to-${data.azurerm_virtual_network.hub-vnet.name}"
  resource_group_name       = azurerm_resource_group.netsec_rg.name
  virtual_network_name      = azurerm_virtual_network.mgmnt-vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub-vnet.id
  allow_forwarded_traffic = true
}


#Route tables

module "route-tables" {
  source = "../../../modules/route-tables"
  resource_group_name = azurerm_resource_group.netsec_rg.name
  subnets = var.subnets
  location = var.location
  suffix = "${azurerm_virtual_network.mgmnt-vnet.name}"
  fws_or_load_balancer_ip = var.fws_or_load_balancer_ip
  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })
}

#Route Table Associasions
resource "azurerm_subnet_route_table_association" "subnet_route_table_association" {
  for_each = { for k, v in azurerm_subnet.subnet : k => v if k != "untrusted-fw-subnet" && k != "trusted-fw-subnet" && k != "mgmt-fw-subnet" }

  subnet_id      = each.value.id
  route_table_id = module.route-tables.route_table_ids[each.key]
}


module "event-hubs-private-endpoint" {
  source = "../../../modules/private-endpoint"
  rg = azurerm_resource_group.netsec_rg.name
  location = azurerm_resource_group.netsec_rg.location
  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })
  spoke_snet_id = azurerm_subnet.subnet["event-hubs-subnet"].id

  private_endpoint = [
    {
        resource_name = azurerm_eventhub_namespace.azure-activity-logs-eventhubs.name
        resource_id = azurerm_eventhub_namespace.azure-activity-logs-eventhubs.id
        subresource_names = [ "namespace" ]
        dns_zone_id = data.azurerm_private_dns_zone.events-hub-dns-zone.id
    }
  ]
}