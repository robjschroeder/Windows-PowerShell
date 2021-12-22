$computersTXTFile = "C:\scripts\windows powershell\work\computers.txt"
$computers = get-content -path $computersTXTFile
$onenote2013EXEPath = "Program Files\Microsoft Office\Office15\onenote.exe"
$shortcutName = "OneNote 2013.lnk"
$startMenuPath = "ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office 2013"
$publicDesktopPath = "users\public\desktop"


foreach ($computer in $computers)
    {
        $adminSharePath = "$computer.server.domain.com\c$"
        if (test-path -Path "\\$adminSharePath" -Verbose)
            {
                
                $TargetFile = "\\$adminSharePath\$onenote2013EXEPath"
                $ShortcutFile = "\\$adminSharePath\$publicDesktopPath\$shortcutName"
                $ShortcutFile1 = "\\$adminSharePath\$startMenuPath\$shortcutName"
                $WScriptShell = New-Object -ComObject WScript.Shell
                $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
                $Shortcut.TargetPath = $TargetFile
                $Shortcut.Save()

                $Shortcut1 = $WScriptShell.CreateShortcut($ShortcutFile1)
                $Shortcut1.TargetPath = $TargetFile
                $Shortcut1.Save()

                if (test-path -Path $ShortcutFile)
                    {
                        write-host OneNote 2013 shortcut created at $ShortcutFile -ForegroundColor Red
                    }
                if (test-path -Path $ShortcutFile1)
                    {
                        write-host OneNote 2013 shortcut created at $ShortcutFile1 -ForegroundColor Red
                    }

            }
        
    }