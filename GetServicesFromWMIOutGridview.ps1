$computer = read-host 'Please enter the computer name you want to retrieve a list of services from'

$netid = read-host 'Please enter your domain\admin username (domain is needed as the variable is NOT appended to it in the command)'

gwmi -Class Win32_Service -ComputerName $computer -Credential $netid | Select-Object -property DisplayName,Name,State,Description | sort-object  -Property DisplayName, State | Out-GridView -Title "Services on computer $computer" -Wait