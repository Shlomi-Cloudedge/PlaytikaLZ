# terraform.tfvars

virtual_network_address_space = ["10.49.200.0/24"]

subnets = {
  trusted-fw-subnet = {
    name             = "trusted-fw-subnet"
    address_prefixes = ["10.49.200.0/27"]
  }
  untrusted-fw-subnet = {
    name             = "untrusted-fw-subnet"
    address_prefixes = ["10.49.200.32/27"]
  }
  mgmt-fw-subnet = {
    name             = "mgmt-fw-subnet"
    address_prefixes = ["10.49.200.64/27"]
  }
  app-gw-subnet = {
    name             = "app-gw-subnet"
    address_prefixes = ["10.49.200.96/27"]
  }
  dns-private-resolver-inbound-subnet = {
    name             = "dns-private-resolver-inbound-subnet"
    address_prefixes = ["10.49.200.128/27"]

    delegations = [
      {
        name = "dns_private_resolver_delegation_inbound"
        service_delegation = {
          name    = "Microsoft.Network/dnsResolvers"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
    ]
  }
  dns-private-resolver-outbound-subnet = {
    name             = "dns-private-resolver-outbound-subnet"
    address_prefixes = ["10.49.200.160/27"]
    delegations = [
      {
        name = "dns_private_resolver_delegation_outbound"
        service_delegation = {
          name    = "Microsoft.Network/dnsResolvers"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
    ]
  }
}


location = "westEurope"

tenant_id = "02f22272-3538-4a5f-ae4e-64cd13d9890e"

connectivity_subscription_id = "0c518f2b-6f6d-412b-8408-faddb4fc5b99"

service_principal_client_id = "8133457b-4ddf-4360-aa6d-5c2a864d1e37"


password_length = 12

resource_group_name = "palo-alto-tf-rg"

environment = "test"

public_ip_name = "mgmnt-public-ip"

vm_name = "palo-alto-vm"
vm_size = "Standard_DS4_v2"

admin_username = "adminuser"

