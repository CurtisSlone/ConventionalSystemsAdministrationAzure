$env:AZCOPY_AUTO_LOGIN_TYPE="SPN"
$env:AZCOPY_SPA_APPLICATION_ID="$(Read-Host -prompt "Enter key")"
$env:AZCOPY_SPA_CLIENT_SECRET="$(Read-Host -prompt "Enter key")"
$env:AZCOPY_TENANT_ID="$(Read-Host -prompt "Enter key")"
azcopy login --service-principal --application-id $env:AZCOPY_SPA_APPLICATION_ID --tenant-id=$env:AZCOPY_TENANT_ID

# azcopy copy <file> <blob-url>