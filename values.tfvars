rg_name     = "domaincontroller-rg"
rg_location = "east us"
default_tags = {
  "env" = "dev"
}
win_vm_name            = "binaryDC"
vnet_name              = "bin_DC_vnet"
subnet_name            = "bin_DC_subnet"
win_vm_nic_name        = "bin_DC_nic"
win_vm_data_disk_name  = "bin_DC_data_disk"
ad_domain_name         = "binarysparklabs.com"

rg_name = "storage-rg"
rg_location = "east us"
default_tags = {
  "name" = "value"
}
storage_account_name = "binsparkteststorage"
storage_container_name = "binsparkcontainer"
application_display_name = "azcopy-app"