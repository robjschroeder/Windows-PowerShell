$credentials = Get-Credential 
$XMLOutputPath = "C:\scripts\Windows Powershell\Work\password.xml"

$credentials | Export-Clixml "$XMLOutputPath"