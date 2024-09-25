output "rg_name" {
  value = module.resource_group.rg_name
}

output "storage_account_name" {
  value = azurerm_storage_account.storage_account.name
}

output "storage_container_id"{
    value = azurerm_storage_container.storage_container.id
}

output "azcopy_app_id" {
    value = azuread_application.az_copy_app.application_id
}

output "azcopy_spn_client_secret"{
    value = azuread_service_principal_password.azcopy_spn_pass.value
    sensitive = true
}

output "storage_account_url" {
    value = azurerm_storage_account.storage_account.primary_connection_string
    sensitive = true
}