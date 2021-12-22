$usbBusType = "USB"
$disks = Get-Disk
$usbDisks = $disks | Where-Object {$_.BusType -eq "$usbBusType"}
$fat32USBDisks = $usbDisks | Where-Object {$_.Size -le 32GB -and $_.Size -gt 1.5GB}
$ntfsUSBDisks = $usbDisks | Where-Object {$_.Size -gt 32GB -and $_.Size -le 64GB}
$compatibleUSBDisks = $USBDisks | Where-Object {$_.Size -gt 1.5GB -and $_.Size -le 64GB}
$numberOfCompatibleUSBDisks = ($compatibleUSBDisks | measure).count
$distRootPath = '\\server.domain.com'
$W10PESE_x64Directory = "$distRootPath\path\WIN10PESE"
$USBDriveLetter = ""
$domain = "server.domain.com"
$netID = Read-host "Please enter your admin networkID ($domain is prepended/appended to your networkID and is not necessary)"
$credentials = get-credential "$domain\$netID-admin"
$mappedDrives = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.DisplayRoot -eq "$distRootPath"}
$diskpartOutput = & diskpart list volume 2>&1 | Out-String

clear
Write-Host "This script will erase and format a USB disk drive, then make it bootable" -ForegroundColor Red
if ($numberOfCompatibleUSBDisks -gt 0)
    {
        Write-Host "The following USB disk drives are present and large enough to be used as a TANS boot disk:" 
        $compatibleUSBDisks
        Write-host `n
        Pause

        if ($numberOfCompatibleUSBDisks -gt 1)
            {
                Write-Host "There are too many compatible USB disk drives plugged in to the machine" -ForegroundColor Red
                Write-Host "Please unplug one of them and run the script again" -ForegroundColor Red
                pause
                exit
            }
        else
            {
                if ($compatibleUSBDisks[0].Size -le 32GB -and $compatibleUSBDisks[0].Size -ge 1.5GB)
                    {
                        $fs = "fat32"
                        $diskNumber = $compatibleUSBDisks[0].Number
                        $diskpartScriptFileName = "DISKPART.TXT"
                        $diskpartScriptFullPath = "$env:USERPROFILE\$diskpartScriptFileName"
                        Write-Host "Creating the disk part script with the drive number for the only compatible USB disk drive"
                        NEW-ITEM –name $diskpartScriptFileName -Path $env:USERPROFILE –itemtype file –force | OUT-NULL
                        Write-Host "Diskpart.txt created at path '$env:USERPROFILE'."
                        $diskpartScriptFile = Get-Item -Path $diskpartScriptFullPath
                        ADD-CONTENT –path $diskpartScriptFullPath “select disk $diskNumber”
                        ADD-CONTENT –path $diskpartScriptFullPath “clean”
                        ADD-CONTENT –path $diskpartScriptFullPath “create partition primary”
                        ADD-CONTENT –path $diskpartScriptFullPath “format fs=$fs quick”
                        ADD-CONTENT –path $diskpartScriptFullPath “active”
                        Write-Host "Running diskpart with the diskpart script created earlier"
                        Start-Process "diskpart.exe" -ArgumentList "/s $diskpartScriptFullPath" -Wait
                        Remove-Item -Path $diskpartScriptFile.FullName | out-null

                        $USBDriveLetter = Read-Host 

                        if ($mappedDrives -eq $null)
                            {
                                New-PSDrive -PSProvider FileSystem -name "R"  -Root $distRootPath -Credential $credentials -Verbose -Scope Global -Persist

                            }

                        
                       
                    }
                elseif ($compatibleUSBDisks[0].Size -le 64GB -and $compatibleUSBDisks[0].Size -gt 32GB)
                    {                        
                        $fs = "ntfs"
                        $diskNumber = $compatibleUSBDisks[0].Number
                        $diskpartScriptFileName = "DISKPART.TXT"
                        $diskpartScriptFullPath = "$env:USERPROFILE\$diskpartScriptFileName"
                        Write-Host "Creating the disk part script with the drive number for the only compatible USB disk drive"                        
                        NEW-ITEM –name $diskpartScriptFileName -Path $env:USERPROFILE –itemtype file –force | OUT-NULL
                        Write-Host "Diskpart.txt created at path '$env:USERPROFILE'."
                        $diskpartScriptFile = Get-Item -Path $diskpartScriptFullPath
                        ADD-CONTENT –path $diskpartScriptFullPath “select disk $diskNumber”
                        ADD-CONTENT –path $diskpartScriptFullPath “clean”
                        ADD-CONTENT –path $diskpartScriptFullPath “create partition primary”
                        ADD-CONTENT –path $diskpartScriptFullPath “format fs=$fs quick”
                        ADD-CONTENT –path $diskpartScriptFullPath “active”
                        Write-Host "Running diskpart with the diskpart script created earlier"
                        Start-Process "diskpart.exe" -ArgumentList "/s $diskpartScriptFullPath" -Wait
                        Remove-Item -Path $diskpartScriptFile.FullName | out-null                           
                    }
            }
    }
else
    {
        Write-Host "There are no compatible USB disks available"
        Write-host `n
        Pause
        exit
    }