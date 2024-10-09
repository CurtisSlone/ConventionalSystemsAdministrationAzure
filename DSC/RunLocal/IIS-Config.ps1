Configuration IIS-Config {
    param
    (
        [Parameter(Mandatory)]
        [String]$IPAddress,

        [Parameter(Mandatory)]
        [String]$HostName,

        [Parameter(Mandatory)]
        [String]$DNSIp

    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDSC
    Import-DscResource -ModuleName NetworkingDsc
    
        Node 'localhost' {
            $Interface = Get-NetAdapter | Where-Object Name -Like "Ethernet*" | Select-Object -First 1
            $InterfaceAlias = $($Interface.Name)
    
            LocalConfigurationManager
            {
                ConfigurationMode = 'ApplyOnly'
                RebootNodeIfNeeded = $true
                ActionAfterReboot = "ContinueConfiguration"
            }
    
            IPAddress 'internalnetwork'
            {
                IPAddress = $IPAddress
                InterfaceAlias = $InterfaceAlias
                AddressFamily = "IPv4"
            }
    
            DnsServerAddress 'DNSServer'
            {
                InterfaceAlias = $InterfaceAlias
                AddressFamily = "IPv4"
                Address = $DNSIp
                DependsOn = "[IPAddress]internalnetwork"
            }
    
            Computer 'hostname'
            {
                Name = $HostName
                DependsOn = "[DNSServerAddress]DNSServer"
            }
            
            WindowsFeature 'WebServer' {
                Ensure = "Present"
                Name   = "Web-Server"
            }

            WindowsFeature 'DirBrowsing' {
                Ensure = "Present"
                Name   = "Web-Dir-Browsing"
            }

            WindowsFeature 'HttpErrors' {
                Ensure = "Present"
                Name   = "Web-Http-Errors"
            }

            WindowsFeature 'WebMgmtTools' {
                Ensure = "Present"
                Name   = "Web-Mgmt-Tools"
            }

            WindowsFeature 'WebMgmtService' {
                Ensure = "Present"
                Name   = "Web-Mgmt-Service"
            }

            WindowsFeature 'WebScriptingTools' {
                Ensure = "Present"
                Name   = "Web-Scripting-Tools"
            }

            WindowsFeature 'WebASP' {
                Ensure = "Present"
                Name   = "Web-ASP"
            }

            WindowsFeature 'WebASPNet45' {
                Ensure = "Present"
                Name   = "Web-Asp-Net45"
            }

            WindowsFeature 'WebISAPIFilter' {
                Ensure = "Present"
                Name   = "Web-ISAPI-Filter"
            }

            WindowsFeature 'WebISAPIEXT' {
                Ensure = "Present"
                Name   = "Web-ISAPI-Ext"
            }
            
        }
    }

    $ConfigData = @{
        AllNodes = @(
            @{
                NodeName = 'localhost'
                PSDscAllowPlainTextPassword = $true
            }
        )
    }

    IIS-Config -IPAddress $ip -HostName $hn -DNSIp $dns -ConfigurationData $ConfigData