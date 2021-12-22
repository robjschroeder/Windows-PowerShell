$configFiles=get-childitem "C:\Deployments\*" -Include *.vbs,*.bat,*.txt, *.sh
$oldServer="server.domain.com\folder"
$newServer="server.domain.com\folder"
foreach ($file in $configFiles)
{
(Get-Content $file.PSPath) | 
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Set-Content $file.PSPath
Write-Output $file.fullname >> C:\Temp\Archived.txt
}


$configFiles=get-childitem "C:\Users\username\Downloads" *.xml
foreach ($file in $configFiles)
{
(Get-Content $file.PSPath) | 
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Foreach-Object {$_.replace("$oldServer","$newServer")} |
Set-Content $file.PSPath
Write-Output $file.fullname >> C:\Temp\Updated.txt
}

get-childitem "C:\Deployments\*" -Include *.vbs,*.bat,*.txt, *.sh | 
ForEach-Object {Copy-Item $_.FullName C:\Temp\Archived}
Write-Output $_.fullname >> C:\Temp\Archived.txt

$destination=C:\Temp\Archived
$configFiles=get-childitem "C:\Deployments\*" -Include "*.vbs","*.bat","*.txt","*.sh
foreach ($file in $configFiles)
{ 
ForEach-Object {Copy-Item $files -Destination $destination}
Write-Output $file.fullname >> C:\Temp\Archived.txt
}

Get-ChildItem "C:\Deployments\*" -Include *.vbs, *.bat, *.txt, *.sh |
ForEach-Object {Copy-Item $_ C:\Temp\Archived}

Copy-Item -Path C:\Deployments\* -Include *.txt, *.vbs, *.bat, *.sh -Recurse `
  -Destination C:\Temp\Archived


$configFiles=get-childitem "C:\Deployments\*" -Include *.vbs,*.bat,*.txt, *.sh |




$T = Get-ChildItem \\$newServer -Recurse | 
$V = Get-ChildItem \\$oldServer -Recurse
Compare-Object $T $V