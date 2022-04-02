#Variables
computerName = Read-Host -prompt "Enter the name of this Domain Controller (ex. DC01)"
localAdminPassword = Read-Host -prompt "Enter your local Administrator password"
secureLocalAdminPassword = ConvertTo-SecureString -AsPlainText $localAdminPassword -Force


#Set Execution Policy
Set-ExecutionPolicy -ExecutionPolicy unrestricted


# Rename Computer
Rename-Computer -NewName $computerName -LocalCredential localhost\Administrator


# Create auto login registry entry for Administrator
New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVerion\Winlogon" -Name "DefaultPassword" -Value $secureLocalAdminPassword
New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVerion\Winlogon" -Name "AutoAdminLogon" -Value 1
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVerion\Winlogon" -Name "DefaultUserName" -Value Administrator


# Create PS1 Script on Administrator's Desktop to Create Domain Forest
createDomainScript = "
# Add the Windows Features for AD

Add-WindowsFeature AD-Domain-Services
Add-windowsfeature RSAT-ADDS

# Prompt For Variables

$SafetModeAdministratorPasswordText = Read-Host -Prompt "Enter your Safe Mode Administrator Password"
$DomainName = Read-Host -Prompt "Enter what you would like your domain to be. (ex. LAB.ADSecurity.org)"
$SiteName = Read-Host -Prompt "Enter what you would like your site name to be (ex. LAB)"

# Convert Text Password To Secure String
$SafeModeAdministratorPassword = ConvertTo-SecureString -AsPlainText $SafetModeAdministratorPasswordText -Force

# Remove registry entries for Auto Logon
Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVerion\Winlogon" -Name "DefaultPassword"
Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVerion\Winlogon" -Name "AutoAdminLogon"

# Create the domain

Import-Module ADDSDeployment

Install-ADDSForest -CreateDNSDelegation:$False -DatabasePath “c:\Windows\NTDS” -DomainMode ‘Win2012’ -DomainName “$DomainName” -DomainNetbiosName “$SiteName” -ForestMode ‘Win2012’ -InstallDNS:$true -LogPath “C:\Windows\NTDS” -NoRebootOnCompletion:$false -Sysvolpath “C:\Windows\SYSVOL” -Force:$true -SafeModeAdministratorPassword $SafeModeAdministratorPassword
"
$createDomainScript | out-file C:\Users\Administrator\Desktop\createDomain.ps1

# Set createDomain script to run on next logon
New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "CreateDomain" -Value "
"C:\Program Files\WindowsPowerShell\powershell.exe" -file "C:\Temp\GetServices.ps1""

# Restart Computer
Restart-Computer
