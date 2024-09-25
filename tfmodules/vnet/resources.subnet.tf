resource "azurerm_subnet" "subnets" {
  for_each = {for idx, subnet in var.var.subnet_address_prefixes : idx => subnet}
  name                         = "subnet-${each.key}"
  resource_group_name          = var.vnet_resource_group
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [each.value]

  depends_on = [ azurerm_virtual_network.vnet ]
}