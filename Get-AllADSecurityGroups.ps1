Import-Module ActiveDirectory

(Get-ADForest).domains | %{
Get-ADGroup -filter {groupCategory -eq 'Security'} | Select Name | Sort-Object Name | Export-CSV -Path "C:\Temp\Sec\SecGroups.csv"
}

$groups = Get-Content C:\Temp\Sec\SecGroups.csv
foreach ($group in $groups){
Get-ADGroupMember -Identity $group | Select samAccountname,@{Name="DisplayName";Expression={(Get-ADUser $_.distinguishedName -Properties Displayname).Displayname}}, @{Name="Title";Expression={(Get-ADUser $_.distinguishedName -Properties Title).title}} | Export-Csv -Path C:\Temp\Sec\$group.csv
}
