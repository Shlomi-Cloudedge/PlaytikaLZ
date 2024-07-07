output "subnet_ids" {
  value = { for name, subnet in azurerm_subnet.subnet : name => subnet.id }
}

output "subnet_address_prefixes" {
  value = { for name, subnet in azurerm_subnet.subnet : name => subnet.address_prefixes }
}

