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
Install-Module -Name xActiveDirectory -RequiredVersion 3.0.0.0 -Force
Install-Module -Name xNetworking -RequiredVersion 5.7.0.0 -Force
Install-Module -Name xStorage -RequiredVersion 3.4.0.0 -Force


exit 0
