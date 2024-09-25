resource "time_rotating" "time_rotation" {
  rotation_days = 180
}

resource "azuread_application" "az_copy_app" {
  display_name = var.application_display_name
  owners = [data.azuread_client_config.current_client.object_id]
}

resource "azuread_application_password" "azcopy_app_password" {
  application_object_id = azuread_application.az_copy_app.object_id
  rotate_when_changed = {
    rotation_days = time_rotating.time_rotation.rotation_days
  }
}

resource "azuread_service_principal" "azcopy_spn" {
  application_id = azuread_application.az_copy_app.application_id
  owners = [data.azuread_client_config.current_client.object_id]
}

resource "azuread_service_principal_password" "azcopy_spn_pass" {
  service_principal_id = azuread_service_principal.azcopy_spn.id
  rotate_when_changed = {
    rotation_days = time_rotating.time_rotation.rotation_days
  }
}
resource "azurerm_role_assignment" "blob_contributor" {
  scope = azurerm_storage_account.storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id = azuread_service_principal.azcopy_spn.id
}