variable "name" {
  description = "Name of the route table"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "disable_bgp_route_propagation" {
  description = "Disable BGP route propagation"
  type        = bool
  default     = false
}

variable "routes" {
  description = "List of routes"
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
