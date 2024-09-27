#
# set policy for the whole system.
#
Set-ExecutionPolicy Unrestricted -Force


#
# Disable SSL for now
#
# add-type @"
#     using System.Net;
#     using System.Security.Cryptography.X509Certificates;
#     public class TrustAllCertsPolicy : ICertificatePolicy {
#         public bool CheckValidationResult(
#             ServicePoint srvPoint, X509Certificate certificate,
#             WebRequest request, int certificateProblem) {
#             return true;
#         }
#     }
# "@
# [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

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
