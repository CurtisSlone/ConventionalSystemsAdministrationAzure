Configuration DC-ConfigAD
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $SafeModePassword,

        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [String]$IPAddress,

        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30
    )
 
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc
    Import-DscResource -ModuleName NetworkingDsc
    Import-DscResource -ModuleName ComputerManagementDSC

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

        Computer 'hostname'{
            Name = "DC01"
            Credential = $Credential
        }

        WindowsFeature 'DNS'
        {
            Ensure = "Present"
            Name = "DNS"
        }
        
        WindowsFeature 'DnsTools'
        {
            Ensure = "Present"
            Name = "RSAT-DNS-Server"
            DependsOn = "[WindowsFeature]DNS"
        }

        WindowsFeature 'ADDS'
        {
            Name   = 'AD-Domain-Services'
            Ensure = 'Present'
            DependsOn = "[WindowsFeature]DNS"
        }

        WindowsFeature 'RSAT'
        {
            Name   = 'RSAT-AD-PowerShell'
            Ensure = 'Present'
            DependsOn = "[WindowsFeature]DNS"
        }

        WindowsFeature 'GPOTools'
        {
            Ensure = "Present"
            Name = "GPMC"
            DependsOn = "[WindowsFeature]DNS"
        }

        WindowsFeature 'DFSTools'
        {
            Ensure = "Present"
            Name = "RSAT-DFS-Mgmt-Con"
            DependsOn = "[WindowsFeature]DNS"
        }

        DnsServerAddress DnsServerAddress
        {
            Address        = '127.0.0.1'
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = 'IPv4'
            DependsOn = "[WindowsFeature]DNS"
        }

        ADDomain 'DomainPromotion'
        {
            DomainName                    = $DomainName
            Credential                    = $Credential
            SafemodeAdministratorPassword = $SafeModePassword
            ForestMode                    = 'WinThreshold'
            DependsOn = @("[WindowsFeature]ADDS", "[DnsServerAddress]DnsServerAddress")
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

DC-ConfigAD -Credential $cred -SafeModePassword $sfpass -DomainName $dn -IPAddress $ip -ConfigurationData $ConfigData