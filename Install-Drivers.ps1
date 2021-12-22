$model = (Get-WmiObject -Class win32_computersystem).Model
$operatingSystem = (Get-WmiObject -Class win32_operatingsystem).version
$driversPath = '\\server.domain.com\d\drivers'
$driversPathx86 = "$driversPath\x86"
$driversPathx64 = "$driversPath\x64"
$filesToUnblock = Get-ChildItem -Path $driversPathx86 -Recurse
$filesToUnblock1 = Get-ChildItem -Path $driversPathx64 -Recurse
$installSwitches = "/s"
$foldersToDelete = 'C:\Dell', 'C:\Intel', 'C:\ProgramData\Microsoft\Windows\Start Menu\Dell Audio', 'C:\Programdata\Microsoft\Windows\Start Menu\Intel'
$successfulInstallsFolder = 'C:\!!Successful Installs'
$installErrorsFolder = 'C:\!!Install Errors'

$filesToUnblock | Unblock-File -Verbose

# Check to see if Windows version is equal to Windows 7 SP1
if ($operatingSystem -eq "6.1.7601")
    {
        $operatingSystemFolderPath = "Windows 7 SP1"
        If ($env:PROCESSOR_ARCHITECTURE -eq "x86")
            {    
                if (!(Test-Path -Path "$driversPathx86\$operatingSystemFolderPath\$model"))
                    {
                        Write-Host "** ""$driversPathx86\$operatingSystemFolderPath\$model"" does not exist **" -ForegroundColor Red >> "$installErrorsFolder\Drivers.txt"
                    }
                Else
                    {
                        $driversToInstall = Get-ChildItem -Path "$driversPathx86\$operatingSystemFolderPath\$model"
                        $numberOfDriversToInstall = $driversToInstall.Count
                        Write-Host "Found $numberOfDriversToInstall drivers to install in location "`'$driversPathx86\$operatingSystemFolderPath\$model`'"" > "$successfulInstallsFolder\Drivers.txt"
                        foreach ($driverToInstall in $driversToInstall)
                            {
                                Write-Host Installing `'$driverToInstall`'...
                                # Start-Process -FilePath $driverToInstall.fullname -ArgumentList $installSwitches -Wait
                                $processFullName = $driverToInstall.FullName
                                $pinfo = New-Object System.Diagnostics.ProcessStartInfo
                                $pinfo.FileName = "$ProcessFullName"
                                $pinfo.RedirectStandardError = $true
                                $pinfo.RedirectStandardOutput = $true
                                $pinfo.UseShellExecute = $false
                                $pinfo.Arguments = "$installSwitches"
                                $p = New-Object System.Diagnostics.Process
                                $p.StartInfo = $pinfo
                                $p.Start() | Out-Null
                                $p.WaitForExit()
                                $stdout = $p.StandardOutput.ReadToEnd()
                                $stderr = $p.StandardError.ReadToEnd()
                                $pExitCode = $p.ExitCode
                                Write-Host "$driverToInstall stdout: $stdout"
                                Write-Host "$driverToInstall finished with exit code: $pExitCode"

                                foreach ($folderToDelete in $foldersToDelete)
                                    {
                                        if (Test-Path $folderToDelete)
                                            {
                                                Write-host "Removing folder `'$folderToDelete`' and its contents" >> "$successfulInstallsFolder\drivers.txt"
                                                Remove-Item -Path $folderToDelete -Force -Recurse -Verbose
                                            }
                                    }
                            }

                    }
            }
        ElseIf ($env:PROCESSOR_ARCHITECTURE -eq "AMD64")
            {
                if (!(Test-Path -Path "$driversPathx64\$model"))
                    {
                        Write-Host "** "$driversPathx64\$model" does not exist **" -ForegroundColor Red
                    }
            }        
    }

# Check to see if Windows version is equal to Windows 8.1
elseif ($operatingSystem -eq "6.3.9600")
    {
        $operatingSystemFolderPath = "Windows 8.1"
        If ($env:PROCESSOR_ARCHITECTURE -eq "x86")
            {    
                if (!(Test-Path -Path "$driversPathx86\$operatingSystemFolderPath\$model"))
                    {
                        Write-Host "** "$driversPathx86\$model" does not exist **" -ForegroundColor Red
                    }
                Else
                    {
                        $driversToInstall = Get-ChildItem -Path "$driversPathx86\$model"
                        $numberOfDriversToInstall = $driversToInstall.Count
                        Write-Host "Found $numberOfDriversToInstall drivers to install in location "`'$driversPathx86\$model`'"" > "$successfulInstallsFolder\Drivers.txt"
                        foreach ($driverToInstall in $driversToInstall)
                            {
                                Write-Host Installing `'$driverToInstall`'...
                                # Start-Process -FilePath $driverToInstall.fullname -ArgumentList $installSwitches -Wait
                                $processFullName = $driverToInstall.FullName
                                $pinfo = New-Object System.Diagnostics.ProcessStartInfo
                                $pinfo.FileName = "$ProcessFullName"
                                $pinfo.RedirectStandardError = $true
                                $pinfo.RedirectStandardOutput = $true
                                $pinfo.UseShellExecute = $false
                                $pinfo.Arguments = "$installSwitches"
                                $p = New-Object System.Diagnostics.Process
                                $p.StartInfo = $pinfo
                                $p.Start() | Out-Null
                                $p.WaitForExit()
                                $stdout = $p.StandardOutput.ReadToEnd()
                                $stderr = $p.StandardError.ReadToEnd()
                                $pExitCode = $p.ExitCode
                                Write-Host "$driverToInstall stdout: $stdout"
                                Write-Host "$driverToInstall finished with exit code: $pExitCode"

                                foreach ($folderToDelete in $foldersToDelete)
                                    {
                                        if (Test-Path $folderToDelete)
                                            {
                                                Write-host "Removing folder `'$folderToDelete`' and its contents" >> "$successfulInstallsFolder\drivers.txt"
                                                Remove-Item -Path $folderToDelete -Force -Recurse -Verbose
                                            }
                                    }
                            }

                    }
            }
        ElseIf ($env:PROCESSOR_ARCHITECTURE -eq "AMD64")
            {
                if (!(Test-Path -Path "$driversPathx64\$model"))
                    {
                        Write-Host "** "$driversPathx64\$model" does not exist **" -ForegroundColor Red
                    }
            }
    }

# Check to see if Windows version is like Windows 10
elseif ($operatingSystem -like "10.*")
    {
        # Check to see if Windows version is equal to Windows 10.0.10240
        if ($operatingSystem -like "10.0.10240*")
            {
            
            }
        # Check to see if Windows version is equal to Windows 10.0.10586
        elseif ($operatingSystem -like "10.0.10586*")
            {
            
            }   
    }
else
    {
        Write-Host "No valid Operating System installed. Operating System installed is: $operatingSystem" >> "$installErrorsFolder\Drivers.txt"
        exit
    }