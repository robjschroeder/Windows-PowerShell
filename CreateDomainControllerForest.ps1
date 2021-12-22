# Add the Windows Features for AD

Add-WindowsFeature AD-Domain-Services
Add-windowsfeature RSAT-ADDS

# Prompt For Variables

$SafetModeAdministratorPasswordText = Read-Host -Prompt "Enter your Safe Mode Administrator Password"
$DomainName = Read-Host -Prompt "Enter what you would like your domain to be. (ex. LAB.ADSecurity.org)"
$SiteName = Read-Host -Prompt "Enter what you would like your site name to be (ex. LAB)"

# Convert Text Password To Secure String
$SafeModeAdministratorPassword = ConvertTo-SecureString -AsPlainText $SafetModeAdministratorPasswordText -Force

# Create the domain

Import-Module ADDSDeployment

Install-ADDSForest -CreateDNSDelegation:$False -DatabasePath “c:\Windows\NTDS” -DomainMode ‘Win2012’ -DomainName “$DomainName” -DomainNetbiosName “$SiteName” -ForestMode ‘Win2012’ -InstallDNS:$true -LogPath “C:\Windows\NTDS” -NoRebootOnCompletion:$false -Sysvolpath “C:\Windows\SYSVOL” -Force:$true -SafeModeAdministratorPassword $SafeModeAdministratorPassword
