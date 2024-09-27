resource "azurerm_storage_account" "storage_account" {
  #   BASIC
  name = var.storage_account_name
  resource_group_name = var.rg_name
  location = var.rg_location
  account_tier = "Standard"
  account_replication_type = "LRS"

  # TAG
    tags = var.default_tags

  # SECURITY
  shared_access_key_enabled = true
  min_tls_version = "TLS1_2"

  # NETWORKING
  public_network_access_enabled = true
  routing {
      choice = "MicrosoftRouting"
  }

  # DATA PROTECTION
  blob_properties {

    delete_retention_policy {
      permanent_delete_enabled = false
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }

    
  }

  # ENCRYPTION
  infrastructure_encryption_enabled = true

  network_rules {
    default_action = "Allow"
    # ip_rules = var.whitelisted_ips
    # virtual_network_subnet_ids = var.whitelisted_subnet
    
  }

}

resource "azurerm_role_assignment" "storage_account_owner" {
  scope = azurerm_storage_account.storage_account.id
  role_definition_name = "Owner"
  principal_id = data.azuread_client_config.current_client.object_id

  depends_on = [ azurerm_storage_account.storage_account ]
}


resource "azurerm_storage_container" "storage_container" {
  name = var.storage_container_name
  storage_account_name = azurerm_storage_account.storage_account.name
  container_access_type = "private"
  depends_on = [ azurerm_role_assignment.storage_account_owner ]
}
