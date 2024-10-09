Configuration WINCA-ConfigHost
{

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
            Address = $DNSIp
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

        WindowsFeature 'RSATADCS'
        {
            Ensure = "Present"
            Name = "RSAT-ADCS"
            DependsOn = "[WindowsFeature]CA"
        }

        WindowsFeature 'RSATADCSMGmt'
        {
            Ensure = "Present"
            Name = "RSAT-ADCS-Mgmt"
            DependsOn = "[WindowsFeature]CA"
        }

        #
        # For Intermediate CAS
        #
        
        WindowsFeature 'CA-Web-Svc'
        {
            Ensure = "Present"
            Name = "ADCS-Web-Enrollment"
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

WINCA-ConfigHost -IPAddress $ip -HostName $hn -DNSIp $dns -ConfigurationData $ConfigData