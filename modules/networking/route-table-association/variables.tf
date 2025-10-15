variable "subnet_id" {
  description = "Subnet ID to associate with route table"
  type        = string
}

variable "route_table_id" {
  description = "Route table ID to associate with subnet"
  type        = string
}
