output "account_sas" {
    value = data.azurerm_storage_account_sas.blob_container_sas.sas
    sensitive = true
}

output "blob_url" {
    value = azurerm_storage_blob.dc_dsc_config_blob.url
}

output "private_link_storage_uri" {
    value = "https://${var.dsc_storage_account_name}.${module.domain_vnet_dns.zone_name}"
}

