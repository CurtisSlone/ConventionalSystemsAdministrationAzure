Configuration IIS-Config {

        Import-DscResource -ModuleName PsDesiredStateConfiguration
    
        Node 'localhost' {
    
            WindowsFeature WebServer {
                Ensure = "Present"
                Name   = "Web-Server"
            }
    
            File WebsiteContent {
                Ensure = 'Present'
                SourcePath = 'c:\test\index.htm'
                DestinationPath = 'c:\inetpub\wwwroot'
            }
        }
    }