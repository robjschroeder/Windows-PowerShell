# NuGet Package Provider name - necessary to install modules via install-module
$nugetPackageName = "NuGet"

# Windows PowerShell ISE Preview module name
$windowsPowerShellISEPreviewPackageName = "PowerShellISE-preview"

# Default User's 'Windows PowerShell' start menu folder path
$defaultUserStartMenuWindowsPowerShellFolderPath = 'C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell'

# Administrator's 'Windows PowerShell' start menu folder path 
$administratorStartMenuWindowsPowerShellFolderPath = 'C:\Users\Administrator\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell'

# Installing the NuGet Package Provider from the PowerShell Gallery
Install-PackageProvider "$nugetPackageName" -Force

# Installing the Windows PowerShell ISE Preview module from the PowerShell Gallery
Install-Module -Name "$WindowsPowerShellISEPreviewPackageName" -Force

# Creating the shortcuts for the Windows PowerShell ISE Preview Module
Install-ISEPreviewShortcuts -force

# Creating the list of Windows PowerShell ISE Preview shortcuts from the Administrator's 'Windows PowerShell' folder
$windowsPowerShellISEPreviewShortcuts = Get-ChildItem -Path "$administratorStartMenuWindowsPowerShellFolderPath" -Filter "Windows PowerShell ISE Preview*"

# Using a For-Each loop to copy the shortcuts in the $windowsPowerShellISEPreviewShortcuts variable to the Default user's Start Menu 
foreach ($windowsPowerShellISEPreviewShortcut in $windowsPowerShellISEPreviewShortcuts)
    {
        Copy-Item -Path $windowsPowerShellISEPreviewShortcut.fullname -Destination "$defaultUserStartMenuWindowsPowerShellFolderPath" -Force -Verbose
    }
