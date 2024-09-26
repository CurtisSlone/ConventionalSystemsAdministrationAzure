rg_name     = "ad-domain-rg"
rg_location = "east us"
default_tags = {
  "env" = "dev"
}
vnet_name = "domain-vnet"
vnet_address_space = ["10.0.0.0/16"]
whitelisted_ips = [""] # Change with your public ip to allow creation of storage container
subnet_address_prefixes = {
    "AzureBastionSubnet" = "10.0.1.0/24",
    "DomainSubnet" = "10.0.2.0/24"
  }

dsc_storage_account_name = "binsparkdscaccount"
dsc_storage_container_name = "binsparkdsccontainer"

private_dns_name = "domainnet"
 virtual_network_link_name = "domainnetlink"

# win_vm_name            = "binaryDC"
# vnet_name              = "bin_DC_vnet"
# subnet_name            = "bin_DC_subnet"
# win_vm_nic_name        = "bin_DC_nic"
# win_vm_data_disk_name  = "bin_DC_data_disk"
# ad_domain_name         = "binarysparklabs.com"
