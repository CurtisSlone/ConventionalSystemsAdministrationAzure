param(
    [Parameter(Mandatory)]
    [String]$newhostname,

    [Parameter(Mandatory)]
    [String]$DomainName,

    [Parameter(Mandatory)]
    [String]$DnsServerIP
)

Rename-Computer -ComputerName (Get-WmiObject Win32_ComputerSystem).Name -NewName $newhostname
$interface = (Get-NetAdapter).Name
Set-DnsClientServerAddress -InterfaceAlias $interface -ServerAddresses $DnsServerIP
Add-Computer -DomainName $DomainName -Credential $cred -Path "OU=Workstations,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"

Enable-PsRemoting -Force

Add-LocalGroupMember -Group "Remote Management Users" -Member "$($DomainName.Split('.')[0])\sg_WorkstationAdmins"

gpupdate /force
