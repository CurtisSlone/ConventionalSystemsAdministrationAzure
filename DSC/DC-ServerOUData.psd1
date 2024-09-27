@{
    AllNodes = @(
        @{
            OUData = @(
                @{
                    OUName = "Servers"
                    OUPath = "OU=Computers,DC=binarysparklabs,DC=com"
                },
                @{
                    OUName = "Windows Servers"
                    OUPath = "OU=Servers,OU=Computers,DC=binarysparklabs,DC=com"
                },
                @{
                    OUName = "Linux Servers"
                    OUPath = "OU=Servers,OU=Computers,DC=binarysparklabs,DC=com"
                },
                @{
                    OUName = "Workstations"
                    OUPath = "OU=Computers,DC=binarysparklabs,DC=com"
                }
            )
        }
    )
}
