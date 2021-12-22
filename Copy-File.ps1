clear-host
Write-Host Run this script as an account that has administrative access on the remote computer`(s`) -ForegroundColor Red
#$filePath = Read-Host Please enter the local path where you stored 'computers.txt'
$filePath = 'C:\users\username'
$fileName = 'computers.txt'
$fullPath = "$filePath\$fileName"
$computers = Get-Content -Path $fullPath
clear-host
$fileName2 = 'File.lnk'
#$filePath2 =  Read-Host Please enter the local path where `'$fileName2`' is stored 
$filePath2 =  "C:\users\username\desktop" 
$fullPath2 = "$filePath2\$fileName2"
#$destinationPath = Read-Host Please enter the path to where you want to copy the file
$destinationPath = "users\pvueproctor\desktop"
$offlineComputers = @()

if (Test-Path $fullPath2)
    {
        Clear-Host
        Write-Host `'$fileName2`' exists at path: $filePath2
        foreach ($computer in $computers)
            {
                If(!(Test-Connection -ComputerName $computer -Count 1 -Quiet))
                    {
                        $offlineComputers += $computer    
                    }

                Else
                    {
                        Copy-Item -Path $fullPath2 -Destination "\\$computer\c$\$destinationPath" -force -verbose                        
                    }                
            }
        If ($offlineComputers.count -gt 0)
                    {
                        Clear-Host
                        Start-Sleep 3
                        Write-Host "The following computers were offline: "-ForegroundColor Red -NoNewline
                        write-host "$offlineComputers." -ForegroundColor Yellow
                    }
    }

<#
foreach ($computer in $computers)
    {
        If(!(Test-Connection -ComputerName $computer -Count 1 -Quiet))
            {
                $offlineComputers += $computer    
            }

        Else
            {
                remove-item -Path "\\$computer\c$\$destinationPath\$filename2" -force -verbose                        
            }                
    }
#>