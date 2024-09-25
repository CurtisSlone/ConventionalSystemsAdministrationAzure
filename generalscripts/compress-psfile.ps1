$compress = @{
    Path = ".\DSC"
    DestinationPath = ".\DSC\*.ps1.zip"
  }
  Compress-Archive @compress