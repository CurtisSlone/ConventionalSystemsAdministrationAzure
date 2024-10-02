param
(
    [Parameter(Mandatory)]
    [String]$DomainName
)

$ADGroups = @(
    @{
        ADGName = "SecGroup_UnprivilegedUsers"
        ADGDistinguishedName = "OU=UnprivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
    },
    @{
        ADGName = "SecGroup_DomainAdmins"
        ADGDistinguishedName = "OU=DomainAdmins,OU=PrivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
    },
    @{
        ADGName = "SecGroup_SystemAdmins"
        ADGDistinguishedName = "OU=SystemAdmins,OU=PrivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
    },
    @{
        ADGName = "SecGroup_PowerShellUSers"
        ADGDistinguishedName = "OU=PrivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
    }
)

foreach ($group in $ADGroups)
{
    New-ADGroup -Name $group.ADGName -SamAccountName $group.ADGName -GroupCategory Security -GroupScope DomainLocal -DisplayName $group.ADGNAme -Path $group.ADGDistinguishedName
}

Get-ADGroup -Filter 'GroupCategory -eq "Security" -and GroupScope -ne "DomainLocal"'