$gponame = Read-Host "Which GPO would you like to backup?"
$path = "C:\Temp\GPORemoved"
Backup-GPO -Name $gponame -Path $path