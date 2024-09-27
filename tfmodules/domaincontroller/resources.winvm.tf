
resource "azurerm_public_ip" "dc-vm-pip" {
  name = "dc-public-ip"
  location = var.rg_location
  resource_group_name = var.rg_name
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_network_interface" "win_vm_nic" {
  name                = var.win_vm_nic_name
  location            = var.rg_location
  resource_group_name = var.rg_name


  ip_configuration {
    name                          = var.subnet_name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.dc_private_ip_address
    public_ip_address_id = azurerm_public_ip.dc-vm-pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.win_vm_nic.id
  network_security_group_id = azurerm_network_security_group.dc_nsg.id

  depends_on = [
    azurerm_network_interface.win_vm_nic,
    azurerm_network_security_group.dc_nsg
  ]
}


resource "azurerm_windows_virtual_machine" "win_vm" {
  name                = var.win_vm_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  size                = "Standard_DS1_v2"
  computer_name       = var.dc_host_name
  admin_username      = var.win_vm_username
  admin_password      = var.win_vm_password
  patch_mode          = "AutomaticByPlatform"
  network_interface_ids = [
    azurerm_network_interface.win_vm_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-gensecond"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.win_vm_nic
  ]
}

resource "azurerm_virtual_machine_extension" "dsc_init" {
  name                       = "dsc-init"
  virtual_machine_id         = azurerm_windows_virtual_machine.win_vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.9"
  depends_on           = [azurerm_windows_virtual_machine.win_vm]

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell -encodedCommand ${textencodebase64(file("${path.module}/../../adminscripts/DSC-Init.ps1"), "UTF-16LE")}"
    }
  SETTINGS
}

# resource "azurerm_virtual_machine_extension" "dc_dsc_config" {
#   name                 = "dc-dsc-config"
#   virtual_machine_id   = azurerm_windows_virtual_machine.win_vm.id
#   publisher            = "Microsoft.Powershell"
#   type                 = "DSC"
#   type_handler_version = "2.77"
#   depends_on           = [azurerm_virtual_machine_extension.dsc_init]


#   settings           = <<SETTINGS
#             {
#                 "WmfVersion": "latest",
#                 "configuration": {
#                   "url": "${var.dc_dsc_url}/ADConfigDC.ps1.zip",
#                   "script": "ADConfigDC.ps1",
#                   "function": "ADConfigDC"
#                 },
#                 "configurationArguments": {
#                   "DomainName": "${var.ad_domain_name}",
#                   "DnsForwarder": "168.63.129.16"
#                 }
#             }
#             SETTINGS

#    protected_settings = <<PROTECTED_SETTINGS
#         {
#             "configurationArguments": {
#                 "adminCreds": {
#                     "UserName": "${var.win_vm_username}",
#                     "Password": "${var.win_vm_password}"
#                 }
#             },
#             "configurationUrlSasToken": "${var.sas_token}"
#         }
#     PROTECTED_SETTINGS
# }