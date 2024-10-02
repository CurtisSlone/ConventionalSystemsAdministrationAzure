Rename-Computer -ComputerName (Get-WmiObject Win32_ComputerSystem).Name -NewName $newhostname

Add-Computer -DomainName $domainName -Credential $cred -Path "OU=Workstations,DC=$($domainName.Split('.')[0]),DC=$($domainName.Split('.')[1])"

Enable-PsRemoting -Force

Add-LocalGroupMember -Group "Remote Management Users" -Member "$($domainName.Split('.')[0])\sg_WorkstationAdmins"
