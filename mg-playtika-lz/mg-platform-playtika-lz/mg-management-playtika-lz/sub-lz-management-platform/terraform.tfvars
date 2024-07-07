location = "westEurope"

log_analytics_sku = "PerGB2018"

virtual_network_address_space = [ "10.49.202.0/24" ]


subnets = {
  tfstates-subnet = {
    name             = "tfstates-subnet"
    address_prefixes = ["10.49.202.0/28"]
  }
  gh-runners-subnet = {
    name             = "mgmt-fw-subnet"
    address_prefixes = ["10.49.202.32/27"]
  }
  event-hubs-subnet = {
    name = "event-hubs-subnet"
    address_prefixes = ["10.49.202.64/28"]
  }
  dr-subnet = {
    name = "dr-machines-subnet"
    address_prefixes = ["10.49.202.80/28"]
  }
}

fws_or_load_balancer_ip = "10.49.200.4"