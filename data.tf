data "azurerm_client_config" "current_client" {}
data "azuread_client_config" "current_client" {}

data "azurerm_storage_account_sas" "blob_container_sas"{
    connection_string = module.dsc_storage.storage_account_connection_string
    https_only = true

    start = var.sas_start
    expiry = var.sas_expiry

    resource_types {
    service   = true
    container = true
    object    = true
    }
    services {
    blob  = true
    queue = false
    table = false
    file  = false
    }
    permissions {
        read    = true
        write   = false
        delete  = false
        list    = true
        add     = false
        create  = false
        update  = false
        process = false
        tag     = false
        filter  = false
    }
    
}

