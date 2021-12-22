# Comma-Separated values file containing computer names
$ADQuery = read-host "Please enter the name of the string to search for in AD for the Building/Room Number (i.e. COMP107)"
$Computers = Get-ADComputer -LDAPFilter "(name=$ADQuery*)" | %{$_.Name}
$NETID = read-host "Please enter your domain\admin username" 
$cred = get-credential $netid

# Path to user profile we want to delete
$profilename = read-host "Please enter the name of the profile you want to delete from the computers"
$profilepath = "C:\Users\$profilename"

# for-each loop that restarts each computer
foreach ($Computer in $Computers){
Get-WmiObject -Class Win32_UserProfile -ComputerName $Computer -Credential $cred | Where-Object { $_.LocalPath -eq $profilepath}.$_Delete()

}