#
# set policy for the whole system.
#
Set-ExecutionPolicy Unrestricted -Force

#
# Install required DSC modules before we get started. 
#
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -Force
Install-Module -Name ComputerManagementDSC -RequiredVersion 8.4.0 -Force
Install-Module -Name ActiveDirectoryDsc -RequiredVersion 6.2.0 -Force
Install-Module -Name NetworkingDsc -RequiredVersion 9.0.0 -Force


exit 0
