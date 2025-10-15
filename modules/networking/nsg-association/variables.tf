variable "subnet_id" {
  description = "Subnet ID to associate with NSG"
  type        = string
}

variable "network_security_group_id" {
  description = "NSG ID to associate with subnet"
  type        = string
}
