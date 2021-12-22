$x86String = "x86"
$x64String = "x64"
$tempPath = 'C:\temp'
$updatesPath = "\\server.domain.com\lync2013\updates"
$updatesx86 = "$updatesPath\$x86String"
$updatesx64 = "$updatesPath\$x64String"
$arguments = "/quiet /norestart"
$x86LyncPath = "${env:ProgramFiles(x86)}\Microsoft Office\Office15\lync.exe" 
$x64LyncPath = "$env:ProgramFiles\Microsoft Office\Office15\lync.exe"
$partialUpdates = "KB2881013","KB2956174","KB3039779"
$fullUpdates =  "KB2863908","KB2889853", "KB2889923","KB2881013","KB2956174","KB3039779"

IF ($env:PROCESSOR_ARCHITECTURE -eq "x86")
    {
        $x86LyncPath = "$env:ProgramFiles\Microsoft Office\Office15\lync.exe"
        $lyncVersion = (Get-Item -Path "$x86LyncPath").VersionInfo.fileversion
        $updates = Get-ChildItem -Path "$updatesx86"
            IF ($lyncVersion -eq "15.0.4420.1017")
                {
                    foreach ($update in $updates)
                        {
                            foreach ($fullUpdate in $fullUpdates)
                                {
                                    IF ($update.name -like "*$fullUpdate*")
                                        {
                                            Start-Process -FilePath "$updatesx86\$update" -ArgumentList "$arguments" -wait
                                        }
                                }
                        }
                }
            Elseif ($lyncVersion -eq "15.0.4569.1503")
                {
                    foreach ($update in $updates)
                        {
                            foreach ($partialUpdate in $partialUpdates)
                                {
                                    IF ($update.name -like "*$partialUpdate*")
                                        {
                                            Start-Process -FilePath "$updatesx86\$update" -ArgumentList "$arguments" -wait
                                        }
                                }
                        }
                }
            Elseif ($lyncVersion -eq   "15.0.4623.1000")
                {
                    foreach ($update in $updates)
                        {
                            foreach ($fullUpdate in $fullUpdates)
                                {
                                    IF ($update.name -like "*$fullUpdate*")
                                        {
                                            Start-Process -FilePath "$updatesx86\$update" -ArgumentList "$arguments" -wait
                                        }
                                }
                        }
                }
            Elseif ($lyncVersion -eq   "15.0.4701.1000")
                {
                    foreach ($update in $updates)
                        {
                            foreach ($fullUpdate in $fullUpdates)
                                {
                                    IF ($update.name -like "*$fullUpdate*")
                                        {
                                            Start-Process -FilePath "$updatesx86\$update" -ArgumentList "$arguments" -wait
                                        }
                                }
                        }
                }
    }
elseif ($env:PROCESSOR_ARCHITECTURE -eq "AMD64")
    {
        IF (Test-Path -Path "$x86LyncPath")
            {
                $lyncVersion = (Get-Item -Path "$x86LyncPath").VersionInfo.fileversion
                $updates = Get-ChildItem -Path "$updatesx86"                
                IF ($lyncVersion -eq "15.0.4420.1017")
                    {
                        foreach ($update in $updates)
                            {
                                foreach ($fullUpdate in $fullUpdates)
                                    {
                                        IF ($update.name -like "*$fullUpdate*")
                                            {
                                                Start-Process -FilePath "$updatesx86\$update" -ArgumentList "$arguments" -wait
                                            }
                                    }
                            }
                    }
                Elseif ($lyncVersion -eq "15.0.4569.1503")
                            {
                                foreach ($update in $updates)
                                    {
                                        foreach ($partialUpdate in $partialUpdates)
                                            {
                                                IF ($update.name -like "*$partialUpdate*")
                                                    {
                                                        Start-Process -FilePath "$updatesx86\$update" -ArgumentList "$arguments" -wait
                                                    }
                                            }
                                    }
                            }
            }
        elseif (Test-Path -Path "$x64LyncPath")
            {
                $lyncVersion = (Get-Item -Path "$x64LyncPath").VersionInfo.fileversion
                $updates = Get-ChildItem -Path "$updatesx64"                
                    IF ($lyncVersion -eq "15.0.4420.1017")
                        {
                            foreach ($update in $updates)
                                {
                                    foreach ($fullUpdate in $fullUpdates)
                                        {
                                            IF ($update.name -like "*$fullUpdate*")
                                                {
                                                    Start-Process -FilePath "$updatesx64\$update" -ArgumentList "$arguments" -wait
                                                }
                                        }
                                }
                        }
                    Elseif ($lyncVersion -eq "15.0.4569.1503")
                        {
                            foreach ($update in $updates)
                                {
                                    foreach ($partialUpdate in $partialUpdates)
                                        {
                                            IF ($update.name -like "*$partialUpdate*")
                                                {
                                                    Start-Process -FilePath "$updatesx64\$update" -ArgumentList "$arguments" -wait
                                                }
                                        }
                                }
                        }  
            }
    }

  