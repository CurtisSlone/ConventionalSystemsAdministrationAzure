Configuration DC-ConfigServerOU
{
    param (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [Array]$OUData
    )

    Import-DscResource -ModuleName xActiveDirectory

    Node localhost {

        LocalConfigurationManager {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        foreach ($ou in $OUData) {
            xADOrganizationalUnit $ou.OUName {
                Name = $ou.OUName
                Path = $ou.OUPath
                Ensure = "Present"
            }
        }

        # Staging Memberservers
        xADComputer IISServer {
            Name = "IIS-Server"
            Path = "OU=Windows Servers,OU=Servers,OU=Computers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            Ensure = "Present"
            DependsOn = "[xADOrganizationalUnit]Windows Servers"
        }

        xADComputer LinuxWebServer {
            Name = "Linux-WebServer"
            Path = "OU=Linux Servers,OU=Servers,OU=Computers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            Ensure = "Present"
            DependsOn = "[xADOrganizationalUnit]Linux Servers"
        }

        xADComputer LinuxCAServer {
            Name = "Linux-CA-Server"
            Path = "OU=Linux Servers,OU=Servers,OU=Computers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            Ensure = "Present"
            DependsOn = "[xADOrganizationalUnit]Linux Servers"
        }
    }
}
