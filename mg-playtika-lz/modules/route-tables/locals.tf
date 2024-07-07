
locals {
  # Filter out the 'fw_subnet'
  filtered_subnets = {
    for key, value in var.subnets : key => value
    if key != "trusted-fw-subnet" || key != "mgmt-fw-subnet" || key != "untrusted-fw-subnet"
  }
}