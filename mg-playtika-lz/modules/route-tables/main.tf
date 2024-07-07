# route-table/main.tf

resource "azurerm_route_table" "route_table" {
for_each = { for k, v in var.subnets : k => v if k != "untrusted-fw-subnet" && k != "trusted-fw-subnet" && k != "mgmt-fw-subnet"}
  name                = "rt-${each.key}-${var.suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "route" {
    for_each = {
      for dest_key, dest_subnet in var.subnets : dest_key => {
        name                   = "to-${dest_key}"
        address_prefix         = dest_subnet.address_prefixes[0]
        next_hop_in_ip_address = var.fws_or_load_balancer_ip
        next_hop_type          = "VirtualAppliance"
      } if dest_key != each.key
    }

    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_in_ip_address = route.value.next_hop_in_ip_address
      next_hop_type          = route.value.next_hop_type
    }
  }
  
  route {
    name                   = "default-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_in_ip_address = var.fws_or_load_balancer_ip
    next_hop_type          = "VirtualAppliance"
  }
  
 tags = var.tags

  lifecycle {
    ignore_changes = [ tags["auto_creation_date"] ]
  }
}