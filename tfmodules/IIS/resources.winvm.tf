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
  network_interface_id      = azurerm_network_interface.iis_vm_nic.id
  network_security_group_id = azurerm_network_security_group.iis_nsg.id

  depends_on = [
    azurerm_network_interface.iis_vm_nic,
    azurerm_network_security_group.iis_nsg
  ]
}