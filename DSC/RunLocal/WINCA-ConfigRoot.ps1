Configuration WINCA-ConfigRoot
{

    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryCSDsc


    node 'localhost'
    {

        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
            ActionAfterReboot = "ContinueConfiguration"
        }

       

        AdcsCertificationAuthority CertificateAuthority
        {
            IsSingleInstance = 'Yes'
            Ensure = 'Present'
            Credential = $Credential
            CAType = 'EnterpriseRootCA'
            # CryptoProviderName = "RSA#Microsoft Software Key Storage Provider"
            # Keylength = 2048
            # HashAlgorithmName = "SHA256"
            # CACommonName = "$($DomainName.Split('.')[0]) Root CA"
            # ValidityPeriodUnits = 25
            # ValidityPeriod = "Years"
            # LogDirectory = "C:\Windows\system32\CertLog\"
        }

    }

}

$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

WINCA-ConfigRoot -Credential $cred -ConfigurationData $ConfigData