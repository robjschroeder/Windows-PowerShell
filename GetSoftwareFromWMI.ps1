$computer = read-host 'Please enter the computer name you want to retrieve a list of software from'

$netid = read-host 'Please enter your domain\admin username (domain is needed as the variable is NOT appended to it in the command)'

gwmi -Class win32_product -ComputerName $computer -Credential $netid | sort-object -Property name | Format-table -Property name,version,identifyingnumber -AutoSize

read-host "Press any key to exit"