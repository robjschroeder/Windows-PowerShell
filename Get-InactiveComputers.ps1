# Variables
Import-Module ActiveDirectory
$domain = "server.domain.com"
$time = (Get-Date).AddDays(-($daysInactive))
$date = Get-Date -Format M.d.yyyy
#$datestr = '{0:yyyyMMdd}' -f $date
$ou="ad ou attribute path"
$server = "server.domain.com"
#$ou="classrooms"

$daysInactive = 7
$time = (Get-Date).AddDays(-($daysInactive))
Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -SearchBase $ou -Properties LastLogonTimeStamp | Sort Name |
  
# Output hostname and lastLogonTimestamp into CSV 
Select-Object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}}, DistinguishedName | export-csv "\\$server\$date - $daysInactive days Inactive Class Computer Report.csv" -NoTypeInformation

$daysInactive = 30
$time = (Get-Date).AddDays(-($daysInactive))
Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -SearchBase $ou -Properties LastLogonTimeStamp | Sort Name |
  
# Output hostname and lastLogonTimestamp into CSV 
Select-Object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}}, DistinguishedName | export-csv "\\$server\$date - $daysInactive days Inactive Class Computer Report.csv" -NoTypeInformation

$daysInactive = 60
$time = (Get-Date).AddDays(-($daysInactive))
Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -SearchBase $ou -Properties LastLogonTimeStamp | Sort Name |
  
# Output hostname and lastLogonTimestamp into CSV 
Select-Object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}}, DistinguishedName | export-csv "\\$server\$date - $daysInactive days Inactive Class Computer Report.csv" -NoTypeInformation

$daysInactive = 90
$time = (Get-Date).AddDays(-($daysInactive))
Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -SearchBase $ou -Properties LastLogonTimeStamp | Sort Name |
  
# Output hostname and lastLogonTimestamp into CSV 
Select-Object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}}, DistinguishedName | export-csv "\\$server\$date - $daysInactive days Inactive Class Computer Report.csv" -NoTypeInformation