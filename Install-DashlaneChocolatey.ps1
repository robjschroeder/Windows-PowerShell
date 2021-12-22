$ErrorActionPreference = "Stop";
 
$packageArgs = @{
  packageName = $env:ChocolateyPackageName
  fileType = "exe"
  silentArgs = "/SD"
  url = "https://d3qm0vl2sdkrc.cloudfront.net/releases/6.1901.0/6.1901.0.16461/release/DashlaneInst.exe"
  validExitCodes = @(0,1223)
  checksum = "017c3e504fa283b48ffca79f2fa7ee0e57e14890"
  checksumType = "sha1"
};
 
Install-ChocolateyPackage @packageArgs
 
$installLocation = Get-AppInstallLocation "dashlane*"
if ($installLocation) {
  Write-Host "$packageName installed to '$installLocation'"
} else {
  Write-Warning "Can't find install location"
}
 
Start-Sleep -Seconds 20
 
Get-Process -Name "dashlane*" | % {
  Write-Host "Stopping $($_.ProcessName) process ($($_.Id)) ..."
  Stop-Process $_
}