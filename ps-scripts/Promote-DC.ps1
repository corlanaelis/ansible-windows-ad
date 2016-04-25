# Windows PowerShell script for AD DS Deployment
param($u,$p)

# Domain Variables
$DomainName = "wyvernsquare"
$DomainMode = "Win2012"
$ForestMode = "Win2012"

$u = "$domainname\$u"

$securePassword = ConvertTo-SecureString -String $p -AsPlainText -Force
$psCreds = new-object -typename System.Management.Automation.PSCredential -argumentlist $u, $securePassword

#AD Admin Password
$admpw = "V@grant1" | ConvertTo-SecureString -AsPlainText -Force

# Path Variables
$DatabasePath = "C:\Windows\NTDS"
$LogPath = "C:\Windows\NTDS"
$SysvolPath = "C:\Windows\SYSVOL"

# Installing needed roles/feautres
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

#Promote Domain Controller and join existing domain in existing forest.
Import-Module ADDSDeployment

Install-ADDSDomainController `
-CreateDnsDelegation:$false `
-DatabasePath $DatabasePath `
-DomainName $DomainName `
-InstallDns:$false `
-LogPath $LogPath `
-NoGlobalCatalog:$false `
-SiteName 'Default-First-Site-Name' `
-SysvolPath $SysvolPath `
-NoRebootOnCompletion:$false `
-Credential $psCreds `
-SafeModeAdministratorPassword $admpw `
-Force:$true