param
(
    [Parameter(Mandatory)]
    [String]$DomainName
)

$CsvFile = ".\ImportADComputers.csv"
$Computers = Import-Csv $CsvFile

Import-Module ActiveDirectory

foreach ($Computer in $Computers)
{
    
    try {
        $NewComputerParms = @{
            Name = $Computer.'ComputerName'
            Path = "OU=Computers,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
        }

        if(Get-ADComputer -Filter "Name -eq '$($Computer.'ComputerName')'")
        {
            Write-Host "Computer already exists" -ForegroundColor Yellow
        } else {
            New-ADComputer @NewComputerParms
            Write-Host "Computer $($Computer.'ComputerName') is created successfully" -ForegroundColor Green
        }
    } catch {
        Write-Host "Failed to create computer $($Computer.'ComputerName') - $($_.Exception.Message)" -ForegroundColor Red
    }
}