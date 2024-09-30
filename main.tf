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
}


#
#
#
# DSC Configuration Blobs
#
#

resource "azurerm_storage_blob" "dc_dsc_config_blob" {
  name = "DC-ConfigAD.ps1.zip"
  storage_account_name = module.dsc_storage.storage_account_name
  storage_container_name = module.dsc_storage.storage_container_name
  type = "Block"
  source = "./DSC/DC-ConfigAD.ps1.zip"

  depends_on = [ module.dsc_storage ]
}

resource "azurerm_storage_blob" "iis_config_blob" {
  name = "IIS-Config.ps1.zip"
  storage_account_name = module.dsc_storage.storage_account_name
  storage_container_name = module.dsc_storage.storage_container_name
  type = "Block"
  source = "./DSC/IIS-Config.ps1.zip"

  depends_on = [ module.dsc_storage ]
}

#
#
#
# Bastion Host
#
#

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

#
#
#
# Domain Controller VM
#
#

module "dc_vm" {
  source = "./tfmodules/domaincontroller"
  rg_name = module.resource_group.rg_name
  rg_location = module.resource_group.rg_location
  default_tags = var.default_tags
  dc_vm_name = var.dc_vm_name
  subnet_name = module.domain_vnet.subnets["DomainSubnet"].name
  subnet_id = module.domain_vnet.subnets["DomainSubnet"].id
  dc_vm_username = var.dc_admin_username
  dc_vm_password = var.dc_admin_password
  dc_vm_nic_name = var.dc_nic_name
  dc_host_name = var.dc_vm_host_name
  dc_private_ip_address = var.dc_private_ip_address
  ad_domain_name = var.ad_domain_name
  dc_config_ad_blob_url = azurerm_storage_blob.dc_dsc_config_blob.url
  sas_token = data.azurerm_storage_account_sas.blob_container_sas.sas
  depends_on = [ azurerm_storage_blob.dc_dsc_config_blob ]
} 

#
#
#
# IIS VM
#
#

# module "iis_vm" {
#   source = "./tfmodules/IIS"
#   rg_name = module.resource_group.rg_name
#   rg_location = module.resource_group.rg_location
#   default_tags = var.default_tags
#   subnet_name = module.domain_vnet.subnets["DomainSubnet"].name
#   subnet_id = module.domain_vnet.subnets["DomainSubnet"].id
#   iis_vm_name = var.iis_vm_name
#   iis_hostname = var.iis_hostname
#   iis_vm_nic_name = var.iis_vm_nic_name
#   iis_private_ip_address = var.iis_private_ip_address
#   iis_vm_username = var.iis_vm_username
#   iis_admin_password = var.iis_admin_password
#   iis_config_blob_url = azurerm_storage_blob.iis_config_blob.url
#   sas_token = data.azurerm_storage_account_sas.blob_container_sas.sas

#   depends_on = [ azurerm_storage_blob.iis_config_blob ]
# } 