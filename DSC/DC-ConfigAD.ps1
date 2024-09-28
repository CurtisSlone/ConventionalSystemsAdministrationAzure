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
                    OUName = "Servers"
                    OUPath = "OU=Computers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                },
                @{
                    OUName = "WindowsServers"
                    OUPath = "OU=Servers,OU=Computers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                },
                @{
                    OUName = "LinuxServers"
                    OUPath = "OU=Servers,OU=Computers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                },
                @{
                    OUName = "Workstations"
                    OUPath = "OU=Computers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                }
            )

            ADOrganizationalUnit 'ComputersOU'
            {
                Name = 'Computers'
                Path = "DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
                Ensure = 'Present'
                DependsOn = "[WaitForADDomain]DomainWait"
            }
            Foreach ($ou in $OUData) {
                ADOrganizationalUnit $ou.OUName {
                    Name = $ou.OUName
                    Path = $ou.OUPath
                    Ensure = "Present"
                    DependsOn = "[ADOrganizationalUnit]ComputersOU"
                }
            }


             # Staging Memberservers
        ADComputer IISServer {
            ComputerName = "IIS"
            Path = "OU=Windows Servers,OU=Servers,OU=Computers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            PsDscRunAsCredential = $Credential
            DependsOn = "[ADOrganizationalUnit]WindowsServers"
        }

        ADComputer LinuxWebServer {
            ComputerName = "LinuxWeb"
            Path = "OU=Linux Servers,OU=Servers,OU=Computers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            PsDscRunAsCredential = $Credential
            DependsOn = "[ADOrganizationalUnit]LinuxServers"
        }

        ADComputer LinuxCAServer {
            ComputerName = "LinuxCA"
            Path = "OU=Linux Servers,OU=Servers,OU=Computers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            PsDscRunAsCredential = $Credential
            DependsOn = "[ADOrganizationalUnit]LinuxServers"
        }

        
    }
}