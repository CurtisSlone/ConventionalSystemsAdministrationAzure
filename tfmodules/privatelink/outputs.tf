output "private_link_fqdn" {
  value = azurerm_private_dns_a_record.dns_a_record.fqdn
}

output "private_link_url" {
  value = azurerm_private_endpoint.private_endpoint.id
}

output "private_record_name" {
  value = azurerm_private_dns_a_record.dns_a_record.name
}

output "a_record_uri" {
  value = "https://${substr(azurerm_private_dns_a_record.dns_a_record.fqdn, 0, length(azurerm_private_dns_a_record.dns_a_record.fqdn) - 1)}"
}