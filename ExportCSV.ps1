$contentPath  = 'C:\scripts\scratch\Machine Online.csv'
$content = Import-Csv $contentPath
$exportedCSVFile = 'C:\scripts\scratch\OnlineMachines.csv'
$onlineComputers = ($content | where-object {$_.status -eq "online"})
$onlineComputers | Export-Csv $exportedCSVFile -NoTypeInformation