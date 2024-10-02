Add-ADGroupMember -Identity SecGroup_UnprivilegedUsers -Members curtis.slone, jerry.smith, gary.howard
Add-ADGroupMember -Identity SecGroup_DomainAdmins -Members curtis.slone.da, gary.howard.da
Add-ADGroupMember -Identity SecGroup_SystemAdmins -Members curtis.slone.sa, jerry.smith.sa

Get-ADGroupMember -Filter "GroupScope -eq 'DomainLocal'"