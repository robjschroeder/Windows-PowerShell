$computerName = Read-Host "Please enter the name of a computer account to enable in Active Directory"
$enableAccountCredential = read-host "Please enter your domain\netID (domain will NOT be appended to this variable, thus is necessary)"

Enable-ADAccount -Identity "$computername$" -Credential "$enableAccountCredential-admin" -Verbose