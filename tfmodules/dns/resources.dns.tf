resource "azurerm_private_dns_zone" "azurerm_private_dns_zone" {
  name = "${var.private_dns_name}.blob.core.windows.net"
  resource_group_name = var.rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name = var.virtual_network_link_name
  resource_group_name = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.azurerm_private_dns_zone.name
  virtual_network_id = var.vnet_id
} 