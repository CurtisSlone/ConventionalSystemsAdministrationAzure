resource "azurerm_subnet" "subnets" {
  for_each = {for idx, subnet in var.subnet_address_prefixes : idx => subnet}
  name                         = "${each.key}"
  resource_group_name          = var.vnet_resource_group
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [each.value]
  service_endpoints = ["Microsoft.Storage"]
  depends_on = [ azurerm_virtual_network.vnet ]
}