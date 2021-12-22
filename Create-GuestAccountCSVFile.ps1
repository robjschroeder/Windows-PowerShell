Import-Module ActiveDirectory
$filterString = Read-Host "Please enter the string you would like to filter by"
$filterAttribute = "sAMAccountName"
$domainName = "domain"
$credentialPrompt = Read-Host "Please enter your domain\AdminnetID (domain is needed)"
$credentials = "$credentialPrompt"
$credentialsPrompt2 = Get-Credential -Credential $credentials 
$searchBase = 'OU=OU,DC=server,DC=domain,DC=com'
$csvFileName = "Output.csv"
$accounts = Get-ADUser -Credential $credentialsPrompt2 -SearchBase $searchBase -Filter {$filterAttribute -like $filterString} -Properties *
$accounts | Select-Object -Property $filterAttribute, Name, Enabled, CannotChangePassword, @{n='LastLogonTimeStamp';e={[DateTime]::FromFileTime($_.lastLogonTimeStamp)}},@{n='pwdLastSet';e={[DateTime]::FromFileTime($_.pwdLastSet)}}, PasswordExpired, PasswordNeverExpires, WhenChanged, WhenCreated, DistinguishedName | Export-Csv $env:USERPROFILE\$csvFileName -Verbose -NoTypeInformation; Invoke-Item -Path $env:USERPROFILE\$csvFileName

Clear-Host
Write-Host "There were"$accounts.count"guest accounts found that are now in the '`$accounts' object." -ForegroundColor Yellow
Write-Host "Please check the CSV file created at: '$env:USERPROFILE\$csvFileName' for more information." -ForegroundColor Yellow