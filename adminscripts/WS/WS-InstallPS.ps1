#
# set policy for the whole system.
#
Set-ExecutionPolicy Unrestricted -Force

#
# Install required DSC modules before we get started. 
#
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -uri "https://github.com/PowerShell/PowerShell/releases/download/v7.4.5/PowerShell-7.4.5-win-x64.zip" -outfile "PowerShell-7.4.5-win-x64.zip"
Expand-Archive -Path ".\PowerShell-7.4.5-win-x64.zip" -DestinationPath 'C:\Program Files\Powershell 7'
