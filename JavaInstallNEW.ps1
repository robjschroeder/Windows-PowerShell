$temp = "C:\temp"
New-Item $temp\JavaInstallStart.txt -ItemType file
if ((gwmi win32_operatingsystem | select osarchitecture).osarchitecture -eq "64-bit")
{
    #64 bit logic here
    $JavaFile = [pscustomobject]@{
    JavaVersion = ''
    FileName = ''
    DownloadURL =  $((Invoke-WebRequest 'http://www.java.com/en/download/manual.jsp').links | where innerHTML -like "Windows Offline (64-bit)" | select href).href
} 
    $JavaFile.FileName = "tempinstaller$(get-date -Format yyMMddmm).exe"
    Invoke-WebRequest $JavaFile.DownloadURL -OutFile ("$temp\"+ $JavaFile.FileName) -ev $DLErr
    if($DLErr){Exit}

    $TempFileName = $JavaFile.FileName
    $JavaFile.JavaVersion = get-item ("$temp\"+ $JavaFile.FileName) | select -ExpandProperty versioninfo | select -ExpandProperty productversion

    $JavaFile.FileName = "jre1."+(((Select-String -Pattern '[0-9]u[0-9]+' -InputObject (get-item ("$temp\$TempFileName")   | select -ExpandProperty versioninfo | select -ExpandProperty originalfilename)) |
ForEach-Object -Process {
  $_.Matches
} |
ForEach-Object -Process {
  $_.Value
}) -replace 'u', '.0_')

Rename-Item -Path "$temp\$TempFileName" -NewName ($JavaFile.FileName+".exe")

Start-Process -Wait -FilePath ("$temp\"+$JavaFile.FileName+".exe") -ArgumentList "/s AUTO_UPDATE=0 WEB_JAVA=1" -PassThru

Remove-Item -Path ("$temp\"+$JavaFile.FileName+".exe") -Force
}
else
{
    #32 bit logic here
    $JavaFile = [pscustomobject]@{
    JavaVersion = ''
    FileName = ''
    DownloadURL =  $((Invoke-WebRequest 'http://www.java.com/en/download/manual.jsp').links | where innerHTML -like "Windows Offline" | select href).href
} 
    $JavaFile.FileName = "tempinstaller$(get-date -Format yyMMddmm).exe"
    Invoke-WebRequest $JavaFile.DownloadURL -OutFile ("$temp\"+ $JavaFile.FileName) -ev $DLErr
    if($DLErr){Exit}

    $TempFileName = $JavaFile.FileName
    $JavaFile.JavaVersion = get-item ("$temp\"+ $JavaFile.FileName) | select -ExpandProperty versioninfo | select -ExpandProperty productversion

    $JavaFile.FileName = "jre1."+(((Select-String -Pattern '[0-9]u[0-9]+' -InputObject (get-item ("$temp\$TempFileName")   | select -ExpandProperty versioninfo | select -ExpandProperty originalfilename)) |
ForEach-Object -Process {
  $_.Matches
} |
ForEach-Object -Process {
  $_.Value
}) -replace 'u', '.0_')

Rename-Item -Path "$temp\$TempFileName" -NewName ($JavaFile.FileName+".exe")

Start-Process -Wait -FilePath ("$temp\"+$JavaFile.FileName+".exe") -ArgumentList "/s AUTO_UPDATE=0 WEB_JAVA=1" -PassThru

Remove-Item -Path ("$temp\"+$JavaFile.FileName+".exe") -Force

}
Exit