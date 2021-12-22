$TempUpdatesPath = "C:\temp\updates"
$TempUpdates32SourcePath = "C:\temp\updates\x86\source"
$TempUpdates64SourcePath = "C:\temp\updates\x64\source"
$TempUpdates32ExtractedPath = "C:\temp\updates\x86\extracted"
$TempUpdates64ExtractedPath = "C:\temp\updates\x64\extracted"
$switches32 = "/extract:$TempUpdates32ExtractedPath /quiet"
$switches64 = "/extract:$TempUpdates64ExtractedPath /quiet"

If (!(Test-Path -Path $TempUpdatesPath))
    {
        New-Item -Path $TempUpdatesPath -ItemType Directory -Force -verbose
        New-Item -Path $TempUpdates32ExtractedPath -ItemType Directory -Force -verbose
        New-Item -Path $TempUpdates32SourcePath -ItemType Directory -Force -verbose
        New-Item -Path $TempUpdates64ExtractedPath -ItemType Directory -Force -verbose
        New-Item -Path $TempUpdates64SourcePath -ItemType Directory -Force -verbose
             
                    
    }

Write-host "Please download all missing 32/64-bit Office updates from Microsoft (download.microsoft.com) and place them in their respective 32/64-bit source folder in C:\Temp\Updates\...\source"
pause

$updates32 = Get-ChildItem -Path $TempUpdates32SourcePath -Filter *.exe
$updates64 = Get-ChildItem -Path $TempUpdates64SourcePath -Filter *.exe

foreach ($update32 in $updates32)
    {
        write-host Extracting update $update32.Name to "$TempUpdates32ExtractedPath"
        Start-Process -FilePath $update32.FullName -ArgumentList $switches32 -Wait        
    }
If ($? -eq $true)
    {
        $extractedupdates32 = Get-ChildItem -Path $TempUpdates32ExtractedPath -Filter *.msp
        Write-Host Extracted $extractedupdates32.count 32-bit updates
    }
foreach ($update64 in $updates64)
    {
        write-host Extracting update $update64.Name to "$TempUpdates64ExtractedPath"
        Start-Process -FilePath $update64.FullName -ArgumentList $switches64 -Wait        
    }
If ($? -eq $true)
    {
        $extractedupdates64 = Get-ChildItem -Path $TempUpdates64ExtractedPath -Filter *.msp
        Write-Host Extracted $extractedupdates64.count 64-bit updates
    }