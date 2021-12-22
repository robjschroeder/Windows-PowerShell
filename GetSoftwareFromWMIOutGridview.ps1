$computer = read-host 'Please enter the computer name you want to retrieve a list of services from'

$netid = read-host 'Please enter your domain\admin username (domain is needed as the variable is NOT appended to it in the command)'

gwmi -Class win32_product -ComputerName $computer -Credential $netid | sort-object -Property name | Select-Object -property Name,Vendor,Version,IdentifyingNumber,InstallDate | Out-GridView -Title "Software on computer $computer" -wait