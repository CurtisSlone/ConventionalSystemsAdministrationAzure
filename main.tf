module "resource_group" {
  source       = "./tfmodules/resourcegroups"
  rg_name      = var.rg_name
  rg_location  = var.rg_location
  default_tags = var.default_tags
}

module "domain_vnet" {
  source = "./tfmodules/vnet"
  vnet_name = var.vnet_name
  vnet_location = module.resource_group.rg_location
  vnet_resource_group = module.resource_group.rg_name
  vnet_address_space = var.vnet_address_space
  subnet_address_prefixes = var.subnet_address_prefixes
}

module "dsc_storage" {
  source = "./tfmodules/storage"
 rg_name = module.resource_group.rg_name
 rg_location = module.resource_group.rg_location
 default_tags = module.resource_group.rg_tags
 storage_account_name = var.dsc_storage_account_name
 storage_container_name = var.dsc_storage_container_name
 whitelisted_ips = [var.whitelisted_ips]
 whitelisted_subnet = [module.domain_vnet.subnets["DomainSubnet"].id]
}

resource "azurerm_storage_blob" "dc_dsc_config_blob" {
  name = "ADConfigDC.ps1.zip"
  storage_account_name = module.dsc_storage.storage_account_name
  storage_container_name = module.dsc_storage.storage_container_name
  type = "Block"
  source = "./DSC/ADConfigDC.ps1.zip"

  depends_on = [ module.dsc_storage ]
}

#
# Private Endpoints Do Not Place Nice with DSC Extenstion
#

module "domain_vnet_dns" {
  source = "./tfmodules/privatednszoneazure"
  rg_name = module.resource_group.rg_name
  private_dns_name = var.private_dns_name
  vnet_id = module.domain_vnet.vnet_id
  virtual_network_link_name = var.virtual_network_link_name

  depends_on = [ module.dsc_storage ]
}

module "dsc_storage_private_link" {
  source = "./tfmodules/privatelink"
  rg_name = module.resource_group.rg_name
  rg_location = module.resource_group.rg_location
  subnet_id = module.domain_vnet.subnets["DomainSubnet"].id

  private_endpoint_name = "dsc-storage-endpoint"
  private_connection_name = "dsc-storage-connection"
  private_connection_resource_id = module.dsc_storage.storage_account_id
  subresources_name = ["blob"]
  private_dns_name = module.domain_vnet_dns.zone_name
  private_dns_zone_id = [module.domain_vnet_dns.private_dns_zone_id]
  a_record_name = "dscstorageaccount"
  a_record_zone_name = module.domain_vnet_dns.zone_name

  depends_on = [ module.domain_vnet_dns ]
}

resource "azurerm_public_ip" "bas-pip" {
  name = "bas-public-ip"
  location = module.resource_group.rg_location
  resource_group_name = module.resource_group.rg_name
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_bastion_host" "bas" {
  name = "domain-bas"
  location = module.resource_group.rg_location
  resource_group_name = module.resource_group.rg_name

  depends_on = [ module.domain_vnet ]

  ip_configuration {
    name = "domain-bas-ip-config"
    subnet_id = module.domain_vnet.subnets["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.bas-pip.id
  }
}

module "dc_win_vm" {
  source = "./tfmodules/domaincontroller"
  rg_name = module.resource_group.rg_name
  rg_location = module.resource_group.rg_location
  default_tags = var.default_tags
  win_vm_name = var.dc_vm_name
  subnet_name = module.domain_vnet.subnets["DomainSubnet"].name
  subnet_id = module.domain_vnet.subnets["DomainSubnet"].id
  win_vm_username = var.dc_admin_username
  win_vm_password = var.dc_admin_password
  win_vm_nic_name = var.dc_nic_name
  dc_host_name = var.dc_vm_host_name
  dc_private_ip_address = var.dc_private_ip_address
  ad_domain_name = var.ad_domain_name
  dc_dsc_url = azurerm_storage_blob.dc_dsc_config_blob.url
  # dc_dsc_url = "https://${var.dsc_storage_account_name}.${module.domain_vnet_dns.zone_name}"
  sas_token = data.azurerm_storage_account_sas.blob_container_sas.sas

  depends_on = [ azurerm_storage_blob.dc_dsc_config_blob ]
} 