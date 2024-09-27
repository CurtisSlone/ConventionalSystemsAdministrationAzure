variable "rg_name" {
  type = string
}

variable "rg_location" {
  type = string
}

variable "default_tags" {
  type = map(string)
}

variable "vnet_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "subnet_address_prefixes" {
  type = map(string)
}

variable "dsc_storage_account_name" {
  type = string
}

variable "dsc_storage_container_name" {
  type = string
}

variable "whitelisted_ips" {
  type = string
}

variable "private_dns_name" {
  type = string
}

variable "virtual_network_link_name" {
  type = string
}

variable "dc_vm_name" {
  type = string
}

variable "dc_nic_name" {
  type = string
}

variable "dc_admin_username" {
  type = string
}

variable "dc_admin_password" {
  type = string
}

variable "dc_vm_host_name" {
  type = string
}

variable "dc_private_ip_address" {
  type = string
}

variable "ad_domain_name" {
  type = string
}

variable "sas_start" {
  type = string
}

variable "sas_expiry" {
  type = string
}