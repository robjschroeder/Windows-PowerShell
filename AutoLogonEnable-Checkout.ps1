$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$RegROPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
$user = "username"
$pass = "password"
$domain = "domain"

Set-ItemProperty $RegPath "AutoAdminLogin" -Value "1" -type String
Set-ItemProperty $RegPath "ForceAutoLogin" -Value "1" -type String
Set-ItemProperty $RegPath "DefaultDomainName" -Value $domain -type String
Set-ItemProperty $RegPath "DefaultUsername" -Value "$user" -type String
Set-ItemProperty $RegPath "DefaultPassword" -Value "$pass" -type String

Exit