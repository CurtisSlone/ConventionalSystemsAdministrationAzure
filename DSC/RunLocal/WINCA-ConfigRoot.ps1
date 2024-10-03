Configuration WINCA-ConfigRoot
{

    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory)]
        [String]$DomainName
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDSC
    Import-DscResource -ModuleName ActiveDirectoryCSDsc

    node 'localhost'
    {
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
            ActionAfterReboot = "ContinueConfiguration"
        }

        Computer 'hostname'
        {
            Name = "WINCA01"
            Credential = $Credential
        }

        WindowsFeature 'ADCert'
        {
            Ensure = "Present"
            Name = "AD-Certificate"
        }

        WindowsFeature 'CA'
        {
            Ensure = "Present"
            Name = "ADCS-Cert-Authority"
        }

        AdcsCertificationAuthority CertificateAuthority
        {
            IsSingleInstance = 'Yes'
            Ensure = 'Present'
            Credential = $Credential
            CAType = 'EnterpriseRootCA'
            DependsOn = '[WindowsFeature] ADCS-Cert-Authority'
            CACommonName = "$($DomainName.Split('.')[0]) Root CA"
            CADistinguishedNameSuffix = "DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
        }

    }

}