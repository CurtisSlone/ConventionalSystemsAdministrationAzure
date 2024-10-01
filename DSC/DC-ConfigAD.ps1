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
        [String]$DnsForwarder,

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

        Script 'SetDNSForwarder'
        {

            # 
            #
            SetScript =
            {
                $dnsrunning = $false
                $triesleft = $Using:RetryCount
                Write-Verbose -Verbose "Checking if DNS service is running."
                While (-not $dnsrunning -and ($triesleft -gt 0))
                {
                    $triesleft--
                    try
                    {
                        $dnsrunning = (Get-Service -name dns).Status -eq "running"
                    } catch {
                        $dnsrunning = $false
                    }
                    if (-not $dnsrunning)
                    {
                        Write-Verbose -Verbose "Waiting $($Using:RetryIntervalSec) seconds for DNS service to start"
                        Start-Sleep -Seconds $Using:RetryIntervalSec
                    }
                }

                $triesleft = $Using:RetryCount
                Write-Verbose "Checking if DNS is responding to WMI."
                do {
                    #
                    # Get-DNSForwarderList would sometimes hang directly after boot.
                    # So, try something with a reasonable timeout first.
                    #
                    try {
                        Write-Verbose -Verbose "Reading DNS through WMI to see if it responds."
                        $dnsObject = Get-CimInstance -ClassName microsoftdns_server -Namespace root/microsoftdns -OperationTimeoutSec 10
                    } catch {
                        $dnsobject = $false
                        Write-Warning -Verbose "Get-Ciminstance for DNS failed: $_"
                    }
                    if ($dnsObject)
                    {
                        $dnsrunning = $true
                    } else {
                        $dnsrunning = $false
                        Write-Verbose -Verbose "Waiting $($Using:RetryIntervalSec) seconds for WMI starting to respond"
                        Start-Sleep -Seconds $Using:RetryIntervalSec
                    }
                    $triesleft--
                } while (-not $dnsrunning -and ($triesleft -gt 0))

                if (-not $dnsrunning)
                {
                    Write-Warning "DNS service is not running, cannot edit forwarder. Template deployment will fail."
                    # but continue anyway.
                }
                try {
                    Write-Verbose -Verbose "Getting list of DNS forwarders"
                    $forwarderlist = Get-DnsServerForwarder
                    if ($forwarderlist.IPAddress)
                    { 
                        Write-Verbose -Verbose "Removing forwarders"
                        Remove-DnsServerForwarder -IPAddress $forwarderlist.IPAddress -Force
                    } else {
                        Write-Verbose -Verbose "No forwarders found"
                    }
                } catch {
                    Write-Warning -Verbose "Exception running Remove-DNSServerForwarder: $_"
                }
                try {
                    Write-Verbose -Verbose "setting  forwarder to $($using:DNSForwarder)"
                    Set-DnsServerForwarder -IPAddress $using:DNSForwarder
                } catch {
                    Write-Warning -Verbose "Exception running Set-DNSServerForwarder: $_"
                }                 
            }
            GetScript =  { @{} }
            TestScript = { $false }
            DependsOn = "[WindowsFeature]DNSTools"
        }

        WindowsFeature 'ADDS'
        {
            Name   = 'AD-Domain-Services'
            Ensure = 'Present'
            DependsOn = "[WindowsFeature]DNS"
        }

        WindowsFeature ADTools
        {
            Ensure = "Present"
            Name = "RSAT-AD-Tools"
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
            DependsOn = @("[WindowsFeature]ADDS", "[DnsServerAddress]DnsServerAddress", "[Script]SetDNSForwarder")
        }

        PendingReboot RebootAfterInstalling
        {
            Name = 'RebootAfterInstalling'
            DependsOn =  "[ADDomain]DomainPromotion"
        }

        WaitForADDomain DomainWait
        {
            DomainName = $DomainName
            RestartCount = 2
            DependsOn = "[PendingReboot]RebootAfterInstalling"
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
    }
}