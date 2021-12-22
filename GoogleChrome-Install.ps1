$path = "C:\Temp"
$installer = "chrome_installer.exe"

Invoke-WebRequest "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile $path\$installer
Start-Process -FilePath $path\$installer -Args "/silent /install" -Verb RunAs -Wait
Remove-Item $path\$installer

Exit