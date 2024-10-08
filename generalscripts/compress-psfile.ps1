$DSCFileArray = @(
  @{
    Path = ".\DSC\RunLocal\DC-ConfigAD.ps1"
    DestinationPath = ".\compressed\DC-DSC.zip"
  },
  @{
    Path = ".\DSC\RunLocal\WINCA-ConfigHost.ps1"
    DestinationPath = ".\compressed\WINCA-DSC.zip"
  },
  @{
    Path = ".\adminscripts\DC\"
    DestinationPath = ".\compressed\\DC.zip"
  },
  @{
    Path = ".\adminscripts\IIS\"
    DestinationPath = ".\compressed\IIS.zip"
  },
  @{
    Path = ".\adminscripts\WINCA\"
    DestinationPath = ".\compressed\WINCA.zip"
  },
  @{
    Path = ".\adminscripts\WS\"
    DestinationPath = ".\compressed\WS.zip"
  }
  )

  foreach ($file in $DSCFileArray){
    Compress-Archive @file
  }
