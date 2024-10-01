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
            # CerticicateId = $certForDSC.Thumbprint

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

        WaitForADDomain DomainWait
        {
            DomainName = $DomainName
            RestartCount = 2
            DependsOn = "[ADDomain]DomainPromotion"
        }

        $OUData = @(
            @{
                OUName = "MemberServers"
                OUPath = "DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            },
            @{
                OUName = "UnprivilegedUsers"
                OUPath = "DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            },
            @{
                OUName = "PrivilegedUsers"
                OUPath = "DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            },
            @{
                OUName = "DomainAdmins"
                OUPath = "OU=PrivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            },
            @{
                OUName = "SystemAdmins"
                OUPath = "OU=PrivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            },
            @{
                OUName = "WorkstationAdmins"
                OUPath = "OU=PrivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            },
            @{
                OUName = "WindowsServers"
                OUPath = "OU=MemberServers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            },
            @{
                OUName = "LinuxServers"
                OUPath = "OU=MemberServers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            },
            @{
                OUName = "Workstations"
                OUPath = "DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            }
        )

        Foreach ($ou in $OUData) {
            ADOrganizationalUnit $ou.OUName {
                Name = $ou.OUName
                Path = $ou.OUPath
                Ensure = "Present"
                DependsOn ="[WaitForADDomain]DomainWait"
            }
        }

        $ComputeData = @(
            @{
                CDName = "IIS01"
                CDPath = "OU=WindowsServers,OU=MemberServers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                CDDnsHostName = "IIS01.$($DomainName)"
                CDDependsOn = "[ADOrganizationalUnit]WindowsServers"
            },
            @{
                CDName = "LinuxWeb01"
                CDPath = "OU=LinuxServers,OU=MemberServers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                CDDnsHostName = "LinuxWeb01.$($DomainName)"
                CDDependsOn = "[ADOrganizationalUnit]LinuxServers"
            },
            @{
                CDName = "LinuxCA01"
                CDPath = "OU=LinuxServers,OU=MemberServers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                CDDnsHostName = "LinuxCA01.$($DomainName)"
                CDDependsOn = "[ADOrganizationalUnit]LinuxServers"
            }
        )

        Foreach ($compute in $ComputeData) {
            ADComputer $compute.CDName
            {
                ComputerName = $compute.CDName
                Path = $compute.CDPath
                # DnsHostName = $compute.CDDnsHostName
                Credential = $Credential

                DependsOn = $compute.CDDependsOn
            }
        }
        

        $ADUsers = @(
            @{
                ADUName = "curtis.slone"
                ADUDisplayName = "Curtis Slone"
                ADUPath = "OU=UnprivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                ADUDependsOn = "[ADOrganizationalUnit]UnprivilegedUsers"
            },
            @{
                ADUName = "jerry.smith"
                ADUDisplayName = "Jerry Smith"
                ADUPath = "OU=UnprivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                ADUDependsOn = "[ADOrganizationalUnit]UnprivilegedUsers"
            },
            @{
                ADUName = "gary.howard"
                ADUDisplayName = "Gary Howard"
                ADUPath = "OU=UnprivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                ADUDependsOn = "[ADOrganizationalUnit]UnprivilegedUsers"
            },
            @{
                ADUName = "curtis.slone.da"
                ADUDisplayName = "Curtis Slone Domain Admin"
                ADUPath = "OU=DomainAdmins,OU=PrivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                ADUDependsOn = "[ADOrganizationalUnit]DomainAdmins"
            },
            @{
                ADUName = "gary.howard.da"
                ADUDisplayName = "Gary Howard Domain Admin"
                ADUPath = "OU=DomainAdmins,OU=PrivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                ADUDependsOn = "[ADOrganizationalUnit]DomainAdmins"
            },
            @{
                ADUName = "curtis.slone.sa"
                ADUDisplayName = "Curtis Slone System Admin"
                ADUPath = "OU=SystemAdmins,OU=PrivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                ADUDependsOn = "[ADOrganizationalUnit]SystemAdmins"
            },
            @{
                ADUName = "jerry.smith.sa"
                ADUDisplayName = "Jerry Smith System Admin"
                ADUPath = "OU=SystemAdmins,OU=PrivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                ADUDependsOn = "[ADOrganizationalUnit]SystemAdmins"
            },
            @{
                ADUName = "curtis.slone.ws"
                ADUDisplayName = "Curtis Slone Workstation Admin"
                ADUPath = "OU=WorkstationAdmins,OU=PrivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                ADUDependsOn = "[ADOrganizationalUnit]WorkstationAdmins"
            }
        )

        Foreach ($user in $ADUsers) {
            ADUser "$($user.ADUName)"
            {
                UserName = $user.ADUName
                DisplayName = $user.ADUDisplayName
                Password = $Credential
                PasswordNeverResets = $true
                CommonName = $user.ADUName
                DomainName = "$($DomainName)"
                Path = $user.ADUPath
                Ensure = "Present"
                DependsOn = $user.ADUDependsOn
            }

        }
        
        $ADGroups = @(
            @{
                ADGName = "SecGroup_UnprivilegedUsers"
                ADGPath = "OU=UnprivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                ADGMembers = @(
                    "$($DomainName.Split('.')[0])\curtis.slone",
                    "$($DomainName.Split('.')[0])\jerry.smith",
                    "$($DomainName.Split('.')[0])\gary.howard"
                )
                ADGDependsOn = "[ADUser]curtis.slone"
            },
            @{
                ADGName = "SecGroup_DomainAdmins"
                ADGPath = "OU=DomainAdmins,OU=PrivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                ADGMembers = @(
                    "$($DomainName.Split('.')[0])\curtis.slone.da",
                    "$($DomainName.Split('.')[0])\gary.howard.da"
                )
                ADGDependsOn = "[ADUser]curtis.slone.da"
            },
            @{
                ADGName = "SecGroup_WorkstationAdmins"
                ADGPath = "OU=WorkstationAdmins,OU=PrivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                ADGMembers = @(
                    "$($DomainName.Split('.')[0])\curtis.slone.ws"
                )
                ADGDependsOn = "[ADUser]curtis.slone.ws"
            },
            @{
                ADGName = "SecGroup_SystemAdmins"
                ADGPath = "OU=SystemAdmins,OU=PrivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                ADGMembers = @(
                    "$($DomainName.Split('.')[0])\curtis.slone.sa",
                    "$($DomainName.Split('.')[0])\jerry.smith.sa"
                )
                ADGDependsOn = "[ADUser]curtis.slone.sa"
            },
            @{
                ADGName = "SecGroup_PowerShellUSers"
                ADGPath = "OU=PrivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                ADGMembers = @(
                    "$($DomainName.Split('.')[0])\curtis.slone.sa"
                )
                ADGDependsOn = "[ADUser]curtis.slone.sa"
            }
        )

        Foreach ($group in $ADGroups) {
            ADGroup $group.ADGName
            {
                GroupName = $group.ADGName
                GroupScope = "DomainLocal"
                Category = "Security"
                Path = $group.ADGPath
                MembershipAttribute = 'SamAccountName'
                Members = $group.ADGMembers
                DisplayName = $group.ADGNAme
                Ensure = "Present"
                DependsOn = $group.ADGDependsOn
            }
        }

        # Script 'Init_GPO' {
        #     SetScript = 
        #     {

        #     }
        #     GetScript =  { @{} }
        #     TestScript = { $false }
        #     DependsOn = "[ADGroup]SecGroup_PowerShellUSers"
        # }
    }
}

$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            $cred = Get-Credential
            $sfpass = Get-Credential
            $dn = Read-Host "Enter Domain Name"
        }
    )
}

DC-ConfigAD -Credential $cred -SafeModePassword $sfpass -DomainName $dn -ConfigurationData $ConfigData