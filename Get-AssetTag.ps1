Clear-Host

$assetTag = (Get-WmiObject -Class win32_systemenclosure -Property *).smbiosassettag
$serialNumber = (Get-WmiObject -Class win32_systemenclosure -Property *).serialnumber
$regKeyPath = "HKLM:\Software\!PathToKey"
$regKeyName = "AssetTag"
$RegistryKey = Get-ItemProperty -Path $regKeyPath
$AssetTagRegistryKey = $RegistryKey.AssetTag 

if (!$assetTag)
    {
        Write-Output "Asset Tag is not set in the BIOS" | Write-Host -ForegroundColor Red
    }
else
    {
        Write-Output " Asset Tag is: $assetTag" | Write-Host -ForegroundColor Yellow
    }
if (!$AssetTagRegistryKey)
    {
        Write-Output "Asset Tag is not set in the Registry" | Write-Host -ForegroundColor Red
    }
else
    {
        Write-Output " Asset Tag in the Registry is: $assetTag" | Write-Host -ForegroundColor Yellow
    }

if (!$serialNumber)
    {
        Write-Output "Serial Number is not set in the BIOS" | Write-Host -ForegroundColor Red
    }
else
    {
        Write-Output "Serial Number is: $serialNumber" | Write-Host -ForegroundColor Yellow
    }