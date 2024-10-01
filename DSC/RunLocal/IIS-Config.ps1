Configuration IIS-Config {
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $SourcePath
    )

        Import-DscResource -ModuleName PsDesiredStateConfiguration
    
        Node 'localhost' {
    
            WindowsFeature WebServer {
                Ensure = "Present"
                Name   = "Web-Server"
            }
    
            File WebsiteContent {
                Ensure = 'Present'
                SourcePath = $SourcePath
                DestinationPath = 'c:\inetpub\wwwroot'
            }
        }
    }