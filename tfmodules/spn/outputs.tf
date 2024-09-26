output "spn_app_id" {
    value = azuread_application.az_copy_app.application_id
}

output "spn_client_secret"{
    value = azuread_service_principal_password.azcopy_spn_pass.value
    sensitive = true
}

