Configuration IIS-Config {

        Import-DscResource -ModuleName PsDesiredStateConfiguration
    
        Node 'localhost' {
    
            WindowsFeature WebServer {
                Ensure = "Present"
                Name   = "Web-Server"
            }
    
            File WebsiteContent {
                Ensure = 'Present'
                SourcePath = 'c:\index.html'
                DestinationPath = 'c:\inetpub\wwwroot'
            }
        }
    }