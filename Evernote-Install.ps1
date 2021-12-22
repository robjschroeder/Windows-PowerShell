$app = "Evernote"
$appPath = "$args[0]"
$appVersion = "$args[1]"
$tempDirectory = 'C:\Temp'
$successfulInstalls = 'C:\!!Successful Installs'
$switches = "/quiet"

IF (!(test-path "$successfulInstalls\$app`_$appVersion.txt"))
    {
        Copy-Item -Path "$appPath" -Destination "$tempDirectory"
            IF ($? -eq "true")
                {
                    $process = Start-Process -FilePath "$tempDirectory\$app`_$appVersion.exe" -ArgumentList $switches -Wait 
                        IF ($? -eq "true")
                            {
                                $installTime = Get-Date -Format F
                                "$app`_$appversion successfully installed on $installTime." | Out-File -FilePath "$successfulInstalls\$app`_$appVersion.txt"                    
                                Remove-Item -Path "$tempDirectory\$app`_$appVersion.exe" -Force
                            }
                        Else
                            {
                                "$App`_$appVersion install failed." | Out-File -FilePath "$tempDirectory\Err.txt"
                                Remove-Item -Path "$tempDirectory\$app`_$appVersion.exe" -Force
                            }
                }
            Else
                {
                    "Copying of files used for installation failed." | Out-File -FilePath "$tempDirectory\Err.txt"
                }
    }
ELSE 
    {
        "$App`_$appVersion is already installed." | Out-File -FilePath "$tempDirectory\Err.txt"
    }