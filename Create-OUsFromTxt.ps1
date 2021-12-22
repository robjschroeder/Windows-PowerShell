$ous = Get-Content "C:\Scripts\Windows PowerShell\Work\ous.txt"
$path = "OU=OU,DC=server,DC=domain,DC=com"
Foreach ($ou in $ous){
New-ADOrganizationalUnit -Name $ou -Path $path
}