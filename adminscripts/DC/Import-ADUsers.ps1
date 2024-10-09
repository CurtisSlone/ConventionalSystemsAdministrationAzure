param
(
    [Parameter(Mandatory)]
    [String]$DomainName
)

# Define the CSV file location and import the data
$Csvfile = ".\ImportADUsers.csv"
$Users = Import-Csv $Csvfile

# The password for the new user
$Password = "1qazxsw2!QAZXSW@"

# Import the Active Directory module
Import-Module ActiveDirectory

# Loop through each user
foreach ($User in $Users) {
    try {      
        $NewUserParams = @{
            Name                  = "$($User.'User logon name')"
            GivenName             = $User.'First name'
            Surname               = $User.'Last name'
            DisplayName           = $User.'Display name'
            SamAccountName        = $User.'User logon name'
            UserPrincipalName     = "$($User.'User logon name')@$($DomainName)"
            Path                  = "$($User.'Path')CN=Users,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            AccountPassword       = (ConvertTo-SecureString "$Password" -AsPlainText -Force)
            Enabled               = $true 
            ChangePasswordAtLogon = $false 
        }
        # Check to see if the user already exists in AD
        if (Get-ADUser -Filter "SamAccountName -eq '$($User.'User logon name')'") {

            # Give a warning if user exists
            Write-Host "A user with username $($User.'User logon name') already exists in Active Directory." -ForegroundColor Yellow
        }
        else {
            # User does not exist then proceed to create the new user account
            # Account will be created in the OU provided by the $User.OU variable read from the CSV file
            New-ADUser @NewUserParams
            Write-Host "The user $($User.'User logon name') is created successfully." -ForegroundColor Green
        }
    }
    catch {
        # Handle any errors that occur during account creation
        Write-Host "Failed to create user $($User.'User logon name') - $($_.Exception.Message)" -ForegroundColor Red
    }
}

