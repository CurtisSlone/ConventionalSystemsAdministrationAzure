param(
    [Parameter(Mandatory)]
    [String]$newhostname,

    [Parameter(Mandatory)]
    [String]$DomainName,

    [Parameter(Mandatory)]
    [String]$DnsServerIP,
    [Parameter(Mandatory)]
    [String]$LocalIP
)

Rename-Computer -ComputerName (Get-WmiObject Win32_ComputerSystem).Name -NewName $newhostname

$interface = (Get-NetAdapter).Name

New-NetIPAddress -InterfaceAlias $interface -IPAddress $LocalIP
Set-NetIPAddress -InterfaceAlias $interface -IPAddress $LocalIP -PrefixLength 24


Set-DnsClientServerAddress -InterfaceAlias $interface -ServerAddresses $DnsServerIP
Add-Computer -DomainName $DomainName -Credential $cred -Path "OU=Workstations,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"

Enable-PsRemoting -Force

Add-LocalGroupMember -Group "Remote Management Users" -Member "$($DomainName.Split('.')[0])\sg_WorkstationAdmins"

gpupdate /force