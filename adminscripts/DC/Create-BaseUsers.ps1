param
    (
        [Parameter(Mandatory)]
        [String]$DomainName
    )

    $Credential = Get-Credential

$ADUsers = @(
            @{
                ADUName = "curtis.slone"
                ADUDisplayName = "Curtis Slone"
                ADUPath = "OU=UnprivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            },
            @{
                ADUName = "jerry.smith"
                ADUDisplayName = "Jerry Smith"
                ADUPath = "OU=UnprivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            },
            @{
                ADUName = "gary.howard"
                ADUDisplayName = "Gary Howard"
                ADUPath = "OU=UnprivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            },
            @{
                ADUName = "curtis.slone.da"
                ADUDisplayName = "Curtis Slone Domain Admin"
                ADUPath = "OU=DomainAdmins,OU=PrivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            },
            @{
                ADUName = "gary.howard.da"
                ADUDisplayName = "Gary Howard Domain Admin"
                ADUPath = "OU=DomainAdmins,OU=PrivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            },
            @{
                ADUName = "curtis.slone.sa"
                ADUDisplayName = "Curtis Slone System Admin"
                ADUPath = "OU=SystemAdmins,OU=PrivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            },
            @{
                ADUName = "jerry.smith.sa"
                ADUDisplayName = "Jerry Smith System Admin"
                ADUPath = "OU=SystemAdmins,OU=PrivilegedUsers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            }
        )

        $DNCap = $DomainName.Split('.')[0].substring(0,1).toupper()+$DomainName.Split('.')[0].substring(1).tolower()

        foreach ($user in $ADUsers)
        {
            New-ADUser -Name $user.ADUName -Path $ou.ADUPAth -DisplayName $user.ADUDisplayName
        }
