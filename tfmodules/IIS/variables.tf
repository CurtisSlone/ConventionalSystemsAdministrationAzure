variable "rg_name" {
  type = string
}

variable "rg_location" {
  type = string
}

variable "default_tags" {
  type = map(string)
}

variable "iis_vm_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "iis_admin_password" {
  type = string
}

variable "iis_vm_nic_name" {
  type = string
}

variable "iis_vm_username" {
  type = string
}

variable "iis_config_blob_url" {
    type = string
}

variable "iis_hostname" {
    type = string
}

variable "iis_private_ip_address" {
  type = string
}

variable "sas_token" {
  type = string
}

variable "iis_nsg_security_rules" {
  type = list(object({
    name = string
    priority = number
    direction = string
    access = string
    protocol = string
    source_port_range = string
    destination_port_range = string
    source_address_prefix = string
  }))

  default = [
  #   {
  #   name                       = "AllowRDP"
  #   priority                   = 100
  #   direction                  = "Inbound"
  #   access                     = "Deny"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "3389"
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }
  ]
}