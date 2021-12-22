# Gets the filter string via read-host and sets it in this variable
$filterString = Read-Host "Please enter the string you would like to filter by"

# Sets the attribute to filter by to "Operating System"
$filterAttribute = "OperatingSystem"

# Domain name used for credentials
$domainName = "server.domain.com"

# Gets the user's netID via read-host and sets it in this variable
$credentialPrompt = Read-Host "Please enter your admin networkID"

# Concatenates all of the values together to form our domain\username value
$credentials = "$domainName"+"\$credentialPrompt"

# User the get-credential cmdlet to get the user's password as a secure string
$credentialsPrompt2 = Get-Credential -Credential $credentials

#set the searchBase in Active Directory to the value specified 
$searchBase = 'OU=OU,DC=server,DC=domain,DC=com'

# Output filename.csv
$csvFileName = "Output.csv"

# Get a list of all computers that match the search filter criteria and puts them in this variable with all available properties
$computers = Get-ADComputer -Credential $credentialsPrompt2 -SearchBase $searchBase -Filter {$filterAttribute -like $filterString} -Properties *

# Exports the computers to the CSV file specified after selecting certain properties and then sorting all of the computers by their name property
$computers | Select-Object -Property Name, DisplayName, Description, Created, Enabled, IPv4Address, OperatingSystem, OperatingSystemVersion, DistinguishedName  | sort Name | Export-Csv $env:USERPROFILE\$csvFileName -Verbose -NoTypeInformation -Force

# Opens the CSV file with the default program associated with it
Invoke-Item -Path $env:USERPROFILE\$csvFileName