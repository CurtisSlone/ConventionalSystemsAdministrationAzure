param
    (
        [Parameter(Mandatory)]
        [String]$DomainName
    )
$OUData = @(
    @{
        OUName = "MemberServers"
        OUPath = "DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
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

# Correct iteration over $OUData
foreach ($ou in $OUData)
{
    # Correct access to hash table properties
    New-ADOrganizationalUnit -Name $ou.OUName -Path $ou.OUPath
}

Get-ADOrganizationalUnit -Filter 'Name -like "*"' | Format-Table Name, DistinguishedName -A
