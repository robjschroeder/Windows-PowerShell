$loc = "\\server.domain.com\jre-7u79"
$ver = "jre_7.0_79"
$newVer = 7.0.79
$installSwitches = "/qn /s WEB_JAVA_SECURITY_LEVEL=M AUTOUPDATECHECK=0 JAVAUPDATE=0 JU=0 IEXPLORER=1 MOZILLA=1 WEB_JAVA=1 /norestart"
$tempDir = "$env:Systemdrive\temp"
$localConfigFilesDir = "$env:SystemRoot\sun\deployment"
$networkConfigFilesDir = '\\server.domain.com\java\config-files'
$configFiles = "$networkConfigFilesDir\deployment.config", "$networkConfigFilesDir\deployment.properties"
$successfulInstallsDir = "$systemroot\!!Successful Installs"

Start-Transcript -Path "$tempDir\Java-Install-transcript.txt"

If (Test-Path "$tempDir\err.txt")
    {
        Remove-Item -Path "$tempDir\err.txt" -Force -Verbose
    }
If (test-path "




Test-Path $configFiles[1]