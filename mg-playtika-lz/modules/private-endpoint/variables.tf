variable "private_endpoint" {
  type = list(object({
    resource_name     = string
    resource_id       = string
    subresource_names = list(string)
    dns_zone_id       = string
  }))
}
variable "rg" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }
variable "spoke_snet_id" { type = string }