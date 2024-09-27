#
# set policy for the whole system.
#
Set-ExecutionPolicy Unrestricted -Force


#
# Download and trust Root Certs 
#
Invoke-WebRequest -Uri "https://cacerts.digicert.com/BaltimoreCyberTrustRoot.crt" -OutFile "C:\Users\BaltimoreCyberTrustRoot.crt"
Invoke-WebRequest -Uri "https://cacerts.digicert.com/DigiCertGlobalRootG2.crt" -OutFile "C:\Users\DigiCertGlobalRootG2.crt"

Import-Certificate -FilePath "C:\Users\BaltimoreCyberTrustRoot.crt" -CertStoreLocation Cert:\LocalMachine\Root
Import-Certificate -FilePath "C:\Users\DigiCertGlobalRootG2.crt" -CertStoreLocation Cert:\LocalMachine\Root

Remove-Item -Path "C:\Users\BaltimoreCyberTrustRoot.crt"
Remove-Item -Path "C:\Users\DigiCertGlobalRootG2.crt"
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
