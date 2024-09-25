resource "azurerm_storage_account" "storage_account" {
  #   BASIC
  name = var.storage_account_name
  resource_group_name = module.resource_group.rg_name
  location = module.resource_group.rg_location
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

  # NETWORKING
  # network_rules {
  #   default_action = "Allow"
  #   ip_rules = ["0.0.0.0/32"]
  # }

  # SAS
  sas_policy {
    expiration_period = "356.00:00:00"
    expiration_action = "Log"
  }
}

resource "azurerm_storage_container" "storage_container" {
  name = var.storage_container_name
  storage_account_name = azurerm_storage_account.storage_account.name
  container_access_type = "private"

}
