$RegKey = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$Name = "EnableLUA"
$Type = "DWord"
$Value = "1"

New-ItemProperty -Path $RegKey -Name $Name -Value $Value -PropertyType $Type -Force -Verbose