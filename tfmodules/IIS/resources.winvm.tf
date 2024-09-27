 resource "azurerm_network_interface" "iis_vm_nic" {
  name                = var.iis_vm_nic_name
  location            = var.rg_location
  resource_group_name = var.rg_name


  ip_configuration {
    name                          = var.subnet_name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.iis_private_ip_address
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.iis_vm_nic
  network_security_group_id = azurerm_network_security_group.iis_nsg

  depends_on = [
    azurerm_network_interface.iis_vm_nic,
    azurerm_network_security_group.iis_nsg
  ]
}

resource "azurerm_windows_virtual_machine" "iis_vm" {
  name                = var.iis_vm_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  size                = "Standard_DS1_v2"
  computer_name       = var.iis_hostname
  admin_username      = var.iis_vm_username
  admin_password      = var.iis_admin_password
  patch_mode          = "AutomaticByPlatform"
  network_interface_ids = [
    azurerm_network_interface.iis_vm_nic.id
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
    azurerm_network_interface.iis_vm_nic
  ]
}

resource "azurerm_virtual_machine_extension" "iis_dsc_config" {
  name                 = "dc-dsc-config"
  virtual_machine_id   = azurerm_windows_virtual_machine.iis_vm.id
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.77"
  depends_on           = [azurerm_virtual_machine_extension.dsc_init]


  settings           = <<SETTINGS
            {
                "WmfVersion": "latest",
                "configuration": {
                  "url": "${var.iis_config_blob_url}",
                  "script": "IIS-Config.ps1",
                  "function": "IIS-Config"
                }
            }
            SETTINGS

   protected_settings = <<PROTECTED_SETTINGS
        {
            "configurationUrlSasToken": "${var.sas_token}",
        }
    PROTECTED_SETTINGS
}