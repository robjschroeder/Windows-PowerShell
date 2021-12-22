Connect-MsolService
$Name = "StudentsWeek7"
$StdErrLog = "C:\Scripts\$Name-err.log"

Start-Transcript -Append -Path $StdErrLog

Import-Module ActiveDirectory

$newSuffix = "domain.server.com"

Get-Content "C:\scripts\deltastudents.txt" | Get-ADUser | ForEach-Object {

#Set AD attributes
    $newUpn = $_.Name + "@" + $newSuffix

    Write-host $_.Name $_.UserPrincipalName $newUpn

 #   $_ | Set-ADUser -UserPrincipalName $newUpn

#Create O365 user, set attributes, and assign to licensing group
    New-MsolUser -UserPrincipalName $newUpn -FirstName $_.GivenName -LastName $_.Surname -DisplayName $_.GivenName

    $id = get-msoluser -UserPrincipalName $newUpn | select objectid,FirstName,LastName

    $DN = $id.FirstName+" "+$id.LastName
    Set-MsolUser -UserPrincipalName $newUpn -DisplayName $DN -UsageLocation US

    Add-MsolGroupMember -GroupObjectId 72f6aa91-94a7-4ac0-ac9e-6a29f6898a9b -GroupMemberType User -GroupMemberObjectId $id.objectid
}
Stop-Transcript

Read-Host -Prompt "Press enter to continue..."