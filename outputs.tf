output "storage_fqdn" {
  value = module.dsc_storage_private_link.private_link_fqdn
}

output "storage_blob_url" {
    value = azurerm_storage_blob.dc_dsc_config_blob.url
}