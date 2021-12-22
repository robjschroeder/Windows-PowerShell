$scriptsDir = 'C:\scripts\windows powershell\work'
$updatesTextFileName = "updates.txt"
$updatesTextFileFullPath = "$scriptsDir\$updatesTextFileName"
$updatesToSearchFor = Get-Content -Path "$updatesTextFileFullPath"
$sourceUpdatesDir = 'C:\temp\x86\source'
$sourceUpdates = Get-ChildItem -Path "$sourceUpdatesDir"
$updatesToInstallDir = 'C:\temp\x86\install'


ForEach ($sourceUpdate in $sourceUpdates)
    {
         ForEach ($updateToSearchFor in $updatesToSearchFor)
            {
                If ($sourceUpdate.FullName -like "*$updateToSearchFor*")
                    {
                        Write-Host Copying $sourceUpdate.Name to "$updatesToInstallDir"
                        Copy-Item -Path $sourceUpdate.FullName -Destination "$updatesToInstallDir" -Force -Verbose
                    }
            }
                     
    }