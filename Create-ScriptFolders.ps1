$successfulInstallsFolder = 'C:\!!Install Errors'
$installErrorsFolder = 'C:\!!Successful Installs'
$tempFolder = 'C:\Temp'


IF (!(test-path -Path $successfulInstallsFolder))
    {
        New-Item -Path $successfulInstallsFolder -ItemType Directory -Force -Verbose
    }
IF (!(test-path -Path $installErrorsFolder))
    {
        New-Item -Path $installErrorsFolder -ItemType Directory -Force -Verbose
    }
IF (!(test-path -Path $tempFolder))
    {
        New-Item -Path $tempFolder -ItemType Directory -Force -Verbose
    }