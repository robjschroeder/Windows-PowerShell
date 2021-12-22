Get-ADComputer -Credential $cred -LDAPFilter "(name=*compname*)" | Select-Object Name | Export-Csv .\renamecomputers.csv -NoTypeInformation

$Members = import-csv .\RenameComputers.csv

foreach ($Member in $Members){

Add-ADGroupMember "ADGroupName" -Members $Member.Name -Credential $cred
}