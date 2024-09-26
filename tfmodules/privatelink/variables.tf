variable "private_dns_name" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "rg_location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "private_endpoint_name" {
  type = string
}
variable "private_connection_name" {
  type = string
}

variable "private_connection_resource_id" {
  type = string
}

variable "subresources_name" {
  type = list(string)
}

variable "private_dns_zone_id" {
  type = list(string)
}

variable "a_record_name" {
  type = string
}

variable "a_record_zone_name" {
  type = string
}