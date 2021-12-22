$chromeUserLevelEXEPath = "AppData\Local\Google\Chrome\Application\chrome.exe"
$switches = "--uninstall -force-uninstall"
#$exclusions = "Google Talk", "GoogleEarth", "Update", "Drive"
  
Stop-Process -Name "Chrome", "GoogleUpdate" 
IF (test-path "C:\users\$env:username\appdata\local\google")
    {
        $chromeVersion = (Get-ChildItem -Path "C:\Users\$env:USERNAME\$chromeUserLevelEXEPath").VersionInfo.FileVersion
        IF (test-path "C:\Users\$env:username\AppData\Local\Google\Chrome\Application\$chromeVersion\installer\setup.exe")
            {
                Start-Process -FilePath "C:\Users\$env:USERNAME\AppData\Local\Google\Chrome\Application\$chromeVersion\installer\setup.exe" -ArgumentList "$switches" -Wait
                IF ($? -eq "true")
                    {
                        Remove-Item "C:\Users\$env:USERNAME\AppData\Local\Google\Chrome" -Force -Recurse
                        Remove-Item "C:\Users\$env:USERNAME\AppData\Local\Google\CrashReports" -Force -Recurse      
                    }                     
            }
    }
ElseIF (test-path "C:\users\$env:username\appdata\local\google\chrome")
    {
        $chromeVersion = (Get-ChildItem -Path "C:\Users\$env:USERNAME\$chromeUserLevelEXEPath").VersionInfo.FileVersion
        IF (test-path "C:\Users\$env:username\AppData\Local\Google\Chrome\Application\$chromeVersion\installer\setup.exe")
            {
                Start-Process -FilePath "C:\Users\$env:USERNAME\AppData\Local\Google\Chrome\Application\$chromeVersion\installer\setup.exe" -ArgumentList "$switches" -Wait
                IF ($? -eq "true")
                    {
                        Remove-Item "C:\Users\$env:USERNAME\AppData\Local\Google\Chrome" -Force -Recurse
                        Remove-Item "C:\Users\$env:USERNAME\AppData\Local\Google\CrashReports" -Force -Recurse  
                    }                     
            }
    }
    