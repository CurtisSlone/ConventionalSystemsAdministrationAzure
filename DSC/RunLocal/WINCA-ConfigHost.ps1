Configuration WINCA-ConfigRoot
{

    param
    (
        [Parameter(Mandatory)]
        [String]$IPAddress,

        [Parameter(Mandatory)]
        [String]$HostName
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDSC
    Import-DscResource -ModuleName NetworkingDsc


    node 'localhost'
    {
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
            Address = "10.0.2.24"
            DependsOn = "[IPAddress]internalnetwork"
        }

        Computer 'hostname'
        {
            Name = $HostName
            DependsOn = "[DNSServerAddress]DNSServer"
        }

        WindowsFeature 'CA'
        {
            Ensure = "Present"
            Name = "ADCS-Cert-Authority"
            DependsOn = "[Computer]hostname"
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

WINCA-ConfigRoot -IPAddress $ip -HostName $hn -ConfigurationData $ConfigData