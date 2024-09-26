variable "vnet_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
  default = ["10.0.0.0/16"]
}

variable "vnet_location" {
    type = string
}

variable "vnet_resource_group"{
    type = string
}

variable "subnet_address_prefixes" {
  type = map(string)
}

