$DSCFileArray = @(
  @{
    Path = ".\DSC\DC-ConfigAD.ps1"
    DestinationPath = ".\DSC\DC-ConfigAD.ps1.zip"
  },
  @{
    Path = ".\DSC\DC-ConfigServerOU.ps1"
    DestinationPath = ".\DSC\DC-ConfigServerOU.ps1.zip"
  },
  @{
    Path = ".\DSC\IIS-Config.ps1"
    DestinationPath = ".\DSC\IIS-Config.ps1.zip"
  }
  )

  foreach ($file in $DSCFileArray){
    Compress-Archive @file
  }
