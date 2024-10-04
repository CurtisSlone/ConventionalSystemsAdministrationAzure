$DSCFileArray = @(
  @{
    Path = ".\DSC\RunLocal\"
    DestinationPath = "RunLocal.zip"
  },
  @{
    Path = ".\adminscripts\WINCA\"
    DestinationPath = ".\adminscripts.zip"
  }
  )

  foreach ($file in $DSCFileArray){
    Compress-Archive @file
  }
