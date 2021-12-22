$PrinterIP = “1.1.1.1”
$PrinterPort = “9100”
$PrinterPortName = “IP_” + $PrinterIP
$DriverName = “HP Laserjet M401n”
$DriverPath = “\\server.domain.com\Printer_Deployment\HP_LaserJet_400_M401”
$DriverInf = “$DriverPath\hpcm401u.INF”
$PrinterCaption = “BldgRoom-P1”
$RegData = "$PrinterCaption,$DriverName,$PrinterPortName"


CreatePrinterPort -PrinterIP $PrinterIP -PrinterPort $PrinterPort -PrinterPortName $PrinterPortName -ComputerName $Env:ComputerName
InstallPrinterDriver -DriverName $DriverName -DriverPath $DriverPath -DriverInf $DriverInf -ComputerName $Env:ComputerName
CreatePrinter -PrinterPortName $PrinterPortName -DriverName $DriverName -PrinterCaption $PrinterCaption -ComputerName $Env:ComputerName