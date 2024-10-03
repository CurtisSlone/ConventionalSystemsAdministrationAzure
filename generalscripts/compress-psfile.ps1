$DSCFileArray = @(
  @{
    Path = ".\DSC\RunLocal\"
    DestinationPath = "RunLocal.zip"
  },
  @{
    Path = ".\adminscripts\"
    DestinationPath = ".\adminscripts.zip"
  }
  )

  foreach ($file in $DSCFileArray){
    Compress-Archive @file
  }
