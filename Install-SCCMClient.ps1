$dataStamp = get-date -Format yyyyMMddTHHmmss
$logFile = "C:\Temp\SCCMClient.log"
$server = "SCCMserver.domain.com"
$site = "siteCode"
$fsp = "server.domain.com"
$mp = "server.domain.com"
$Args = @(
    "/i"
    "\\$server\SCCM_Client_Install\ccmsetup.msi"
    "/SMSSITECODE=$site"
    "/FSP=$fsp"
    "/MP=$mp"
    "/qn"
    "/norestart"
    $logFile
)
Start-Process "msiexec.exe" -ArgumentList $Args -Wait -NoNewWindow