#
# This DSC is used as an aggregate of all the other DC DSC Files
# Just in case an admin uses DSC directly from a PS shell on the DC
#

Configuration DC-SetupLCM{
    LocalConfigurationManager {
        ConfigurationMode = 'ApplyOnly'
        AllowModuleOverwrite = $true
        RebootNodeIfNeeded = $true
        PartialConfigurations = @(
            @{
                Name = "DC-ConfigAD"
            },
            @{
                Name = "DC-ConfigServerOU"
            }
        )
    }
}

# Apply LCM configuration
SetupLCM

# Apply partial configurations
Start-DscConfiguration -Path ".\DC-ConfigAD" -Wait -Verbose -Force
Start-DscConfiguration -Path ".\DC-ConfigServerOU" -Wait -Verbose -Force
