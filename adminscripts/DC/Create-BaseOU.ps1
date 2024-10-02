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

foreach ($ou in $OUData)
{
    New-ADOrganizationalUnit -Name $ou.OUName -Path $ou.OUPath
}

Get-ADOrganizationalUnit -Filter 'Name -like "*"' | Format-Table Name, DistinguishedName -A
