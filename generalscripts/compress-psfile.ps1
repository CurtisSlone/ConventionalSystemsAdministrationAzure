$dcdsccompress = @{
    Path = ".\DSC\ADConfigDC.ps1"
    DestinationPath = ".\DSC\ADConfigDC.ps1.zip"
  }
  Compress-Archive @dcdsccompress