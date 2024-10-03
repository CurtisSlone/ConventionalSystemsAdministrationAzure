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

    }

}