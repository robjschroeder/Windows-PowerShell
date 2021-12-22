$adobeConnectAddInFileName = "adobeconnectaddin.exe"
$adobeConnectAddInFullPath = '\\server.domain.com\path\plugin\Adobe Connect Add In Checker'
$adobeConnectAddInDeployVersion = ((Get-Item -Path "$adobeConnectAddInFullPath\$adobeConnectAddInFileName").VersionInfo).fileversion
$adobeConnectAddInDeployVersion = $adobeConnectAddInDeployVersion -replace (",", ".")
$adobeConnectAddInDeployFiles = get-childitem -Path "$adobeConnectAddInFullPath"
$adobeConnectAddIn32bitProgramFilesPath = 'C:\Program Files\Adobe\Adobe Connect Add In Checker'
$adobeConnectAddIn64bitProgramFilesPath = 'C:\Program Files (x86)\Adobe\Adobe Connect Add In Checker'
$vbScriptFileName = 'runaddinchecker.vbs'
$startupFolderPath = "$env:programdata"+'\microsoft\windows\start menu\programs\startup'
$usersFolderPath = 'C:\users'
$users = Get-ChildItem -Path $usersFolderPath -Exclude 'Default', '*-admin', 'Public', 'Defprof', 'Administrator'
$adobeConnectAddInAppdataFolderPath = 'appdata\roaming\Macromedia\Flash Player\www.macromedia.com\bin\adobeconnectaddin'
$32bitFilestoCopy = "$adobeConnectAddIn32bitProgramFilesPath\adobeconnectaddin.exe", "$adobeConnectAddIn32bitProgramFilesPath\digest.s", 
                    "$adobeConnectAddIn32bitProgramFilesPath\cefpackage.zip", "$adobeConnectAddIn32bitProgramFilesPath\cefDigest.s" 
$64bitFilesToCopy = "$adobeConnectAddIn64bitProgramFilesPath\adobeconnectaddin.exe", "$adobeConnectAddIn64bitProgramFilesPath\digest.s", 
                    "$adobeConnectAddIn64bitProgramFilesPath\cefpackage.zip", "$adobeConnectAddIn64bitProgramFilesPath\cefDigest.s"
$HKLMRunKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
$HKLMRunKeyName = "AdobeConnectProAddIns"
$HKLMRunKey32Value = "$adobeConnectAddIn32bitProgramFilesPath\$vbScriptFileName"
$HKLMRunKey64Value = "$adobeConnectAddIn64bitProgramFilesPath\$vbScriptFileName"
$regKeyType = "String"  

If ($env:PROCESSOR_ARCHITECTURE -eq "x86")
    {
        if (!(Test-Path -Path "$adobeConnectAddIn32bitProgramFilesPath"))
            {
                Copy-Item -Path "$adobeConnectAddInFullPath" -Destination "$adobeConnectAddIn32bitProgramFilesPath" -Force -Recurse

                New-ItemProperty -Path "$HKLMRunKey" -Name "$HKLMRunKeyName" -Value "$HKLMRunKey32Value" -PropertyType "$regKeyType" -Force

                foreach ($user in $users)
                    {
                        if (!(test-path -Path $user\$adobeConnectAddInAppdataFolderPath))
                            {
                                New-Item -Path "$user\appdata\roaming\Macromedia" -ItemType Directory -Force 
                                New-Item -Path "$user\appdata\roaming\Macromedia\Flash Player" -ItemType Directory -Force 
                                New-Item -Path "$user\appdata\roaming\Macromedia\Flash Player\www.macromedia.com" -ItemType Directory -Force 
                                New-Item -Path "$user\appdata\roaming\Macromedia\Flash Player\www.macromedia.com\bin" -ItemType Directory -Force 
                                New-Item -Path "$user\appdata\roaming\Macromedia\Flash Player\www.macromedia.com\bin\adobeconnectaddin" -ItemType Directory -Force

                                foreach ($32BitFile in $32bitFilestoCopy)
                                    {
                                        Copy-Item -Path $32BitFile -Destination "$user\$adobeConnectAddInAppdataFolderPath" -Force 
                                    }
                            }
                        else
                            {
                                foreach ($32BitFile in $32bitFilestoCopy)
                                    {
                                        Copy-Item -Path $32BitFile -Destination "$user\$adobeConnectAddInAppdataFolderPath" -Force 
                                    }
                            }
                    }
            }
        else
            {
                $adobeConnectAddInInstalledVersion = ((Get-Item -Path "$adobeConnectAddIn32bitProgramFilesPath\$adobeConnectAddInFileName").VersionInfo).fileversion
                $adobeConnectAddInInstalledVersion = $adobeConnectAddInInstalledVersion -replace (",", ".")

                if ($adobeConnectAddInInstalledVersion -lt "$adobeConnectAddInDeployVersion")
                    {
                        foreach($DeployFile in $adobeConnectAddInDeployFiles)
                            {
                                Copy-Item -Path $DeployFile -Destination "$adobeConnectAddIn32bitProgramFilesPath" -Force
                            }
                        New-ItemProperty -Path "$HKLMRunKey" -Name "$HKLMRunKeyName" -Value "$HKLMRunKey32Value" -PropertyType "$regKeyType" -Force

                        foreach ($user in $users)
                            {
                                if (!(test-path -Path $user\$adobeConnectAddInAppdataFolderPath))
                                    {
                                        New-Item -Path "$user\appdata\roaming\Macromedia" -ItemType Directory -Force 
                                        New-Item -Path "$user\appdata\roaming\Macromedia\Flash Player" -ItemType Directory -Force 
                                        New-Item -Path "$user\appdata\roaming\Macromedia\Flash Player\www.macromedia.com" -ItemType Directory -Force 
                                        New-Item -Path "$user\appdata\roaming\Macromedia\Flash Player\www.macromedia.com\bin" -ItemType Directory -Force 
                                        New-Item -Path "$user\appdata\roaming\Macromedia\Flash Player\www.macromedia.com\bin\adobeconnectaddin" -ItemType Directory -Force

                                        foreach ($32BitFile in $32bitFilestoCopy)
                                            {
                                                Copy-Item -Path $32BitFile -Destination "$user\$adobeConnectAddInAppdataFolderPath" -Force 
                                            }
                                    }
                                else
                                    {
                                        foreach ($32BitFile in $32bitFilestoCopy)
                                            {
                                                Copy-Item -Path $32BitFile -Destination "$user\$adobeConnectAddInAppdataFolderPath" -Force 
                                            }
                                    }
                            }
                    }
            }

    }
ElseIf ($env:PROCESSOR_ARCHITECTURE -eq "AMD64")
    {
        if (!(Test-Path -Path "$adobeConnectAddIn64bitProgramFilesPath"))
            {
                Copy-Item -Path "$adobeConnectAddInFullPath" -Destination "$adobeConnectAddIn64bitProgramFilesPath" -Force -Recurse

                New-ItemProperty -Path "$HKLMRunKey" -Name "$HKLMRunKeyName" -Value "$HKLMRunKey64Value" -PropertyType "$regKeyType" -Force

                foreach ($user in $users)
                    {
                        if (!(test-path -Path $user\$adobeConnectAddInAppdataFolderPath))
                            {
                                New-Item -Path "$user\appdata\roaming\Macromedia" -ItemType Directory -Force 
                                New-Item -Path "$user\appdata\roaming\Macromedia\Flash Player" -ItemType Directory -Force 
                                New-Item -Path "$user\appdata\roaming\Macromedia\Flash Player\www.macromedia.com" -ItemType Directory -Force 
                                New-Item -Path "$user\appdata\roaming\Macromedia\Flash Player\www.macromedia.com\bin" -ItemType Directory -Force 
                                New-Item -Path "$user\appdata\roaming\Macromedia\Flash Player\www.macromedia.com\bin\adobeconnectaddin" -ItemType Directory -Force

                                foreach ($64BitFile in $64bitFilestoCopy)
                                    {
                                        Copy-Item -Path $64BitFile -Destination "$user\$adobeConnectAddInAppdataFolderPath" -Force 
                                    }
                            }
                        else
                            {
                                foreach ($64BitFile in $64bitFilestoCopy)
                                    {
                                        Copy-Item -Path $64BitFile -Destination "$user\$adobeConnectAddInAppdataFolderPath" -Force 
                                    }
                            }
                    }
            }
        else
            {
                $adobeConnectAddInInstalledVersion = ((Get-Item -Path "$adobeConnectAddIn64bitProgramFilesPath\$adobeConnectAddInFileName").VersionInfo).fileversion
                $adobeConnectAddInInstalledVersion = $adobeConnectAddInInstalledVersion -replace (",", ".")

                if ($adobeConnectAddInInstalledVersion -lt "$adobeConnectAddInDeployVersion")
                    {
                        foreach($DeployFile in $adobeConnectAddInDeployFiles)
                            {
                                Copy-Item -Path $DeployFile -Destination "$adobeConnectAddIn32bitProgramFilesPath" -Force
                            }
                        New-ItemProperty -Path "$HKLMRunKey" -Name "$HKLMRunKeyName" -Value "$HKLMRunKey64Value" -PropertyType "$regKeyType" -Force

                        foreach ($user in $users)
                            {
                                if (!(test-path -Path $user\$adobeConnectAddInAppdataFolderPath))
                                    {
                                        New-Item -Path "$user\appdata\roaming\Macromedia" -ItemType Directory -Force 
                                        New-Item -Path "$user\appdata\roaming\Macromedia\Flash Player" -ItemType Directory -Force 
                                        New-Item -Path "$user\appdata\roaming\Macromedia\Flash Player\www.macromedia.com" -ItemType Directory -Force 
                                        New-Item -Path "$user\appdata\roaming\Macromedia\Flash Player\www.macromedia.com\bin" -ItemType Directory -Force 
                                        New-Item -Path "$user\appdata\roaming\Macromedia\Flash Player\www.macromedia.com\bin\adobeconnectaddin" -ItemType Directory -Force

                                        foreach ($64BitFile in $64bitFilestoCopy)
                                            {
                                                Copy-Item -Path $64BitFile -Destination "$user\$adobeConnectAddInAppdataFolderPath" -Force 
                                            }
                                    }
                                else
                                    {
                                        foreach ($64BitFile in $64bitFilestoCopy)
                                            {
                                                Copy-Item -Path $64BitFile -Destination "$user\$adobeConnectAddInAppdataFolderPath" -Force 
                                            }
                                    }
                            }
                    }
            }    
    }