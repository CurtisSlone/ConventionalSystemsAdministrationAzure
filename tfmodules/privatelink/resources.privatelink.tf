resource "azurerm_private_endpoint" "private_endpoint" {
  name                = var.private_endpoint_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_id
 
  private_service_connection {
    name                           = var.private_connection_name
    private_connection_resource_id = var.private_connection_resource_id
    subresource_names              = var.subresources_name
    is_manual_connection           = false
  }
 
  private_dns_zone_group {
    name                 = var.private_connection_name
    private_dns_zone_ids = var.private_dns_zone_id
  }
}

resource "azurerm_private_dns_a_record" "dns_a_record" {
  name                = var.a_record_name
  zone_name           = var.a_record_zone_name
  resource_group_name = var.rg_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.private_endpoint.private_service_connection.0.private_ip_address]
}