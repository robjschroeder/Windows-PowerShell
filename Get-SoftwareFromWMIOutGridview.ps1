$computer = read-host 'Please enter the computer name you want to retrieve a list of software from'

gwmi -Class win32_product -ComputerName $computer -Credential $cred | sort-object -Property name | Select-Object -property Name,Vendor,Version,IdentifyingNumber,InstallDate | Out-GridView -Title "Software on computer $computer" -wait