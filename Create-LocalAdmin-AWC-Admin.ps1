$username = "AdminUsername"
$password = ConvertTo-SecureString "testPassword" -AsPlainText -Force
$group = "Administrators"

New-LocalUser -Name "$username" -Password $password -FullName "Full Name" -Description "Local admin account NOT built-in"
Add-LocalGroupMember -Group "$group" -Member "$username"