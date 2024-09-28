rg_name     = "ad-domain-rg"
rg_location = "east us"
default_tags = {
  "env" = "dev"
}

vnet_name = "domain-vnet"
vnet_address_space = ["10.0.0.0/16"]
subnet_address_prefixes = {
    "AzureBastionSubnet" = "10.0.1.0/24",
    "DomainSubnet" = "10.0.2.0/24"
  }

dsc_storage_account_name = "binsparkdscaccount"
dsc_storage_container_name = "binsparkdsccontainer"
sas_start = "2024-09-28T00:00:00Z"
sas_expiry = "2024-09-30T00:00:00Z"

private_dns_name = "privatelink.blob.core.windows.net"
virtual_network_link_name = "domainnetlink"

dc_vm_name = "BINSPARKDC"
dc_nic_name = "binsparkdcnic"
dc_admin_username = "binwinadmin"
dc_vm_host_name = "BINSPARKDC"
dc_private_ip_address = "10.0.2.24"
ad_domain_name         = "binarysparklabs.com"

iis_vm_name = "BINSPARKIIS"
iis_hostname = "BINSPARKIIS"
iis_vm_nic_name = "binsparkiisnic"
iis_vm_username = "binwinadmin"
iis_private_ip_address = "10.0.2.25"

