$name = "Ricoh Aficio MP 3353"
$port = "IP_1.1.1.1"
$driver = "Ricoh Aficio MP 3350 PCL6"

Add-Printer -Name $name -PortName $port -DriverName $driver -Verbose

Get-Printer -Name $name