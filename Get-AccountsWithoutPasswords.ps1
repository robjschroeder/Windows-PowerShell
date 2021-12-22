# Create admin folder
New-Item -Path c:\temp\nopasswdaccounts -ItemType directory -force
# Get domain dn
$domainDN = get-addomain | select -ExpandProperty DistinguishedName
# Save pwnotreq users to txt
$query = Get-ADUser -Properties Name,distinguishedname,useraccountcontrol,objectClass -LDAPFilter "(&(userAccountControl:1.2.840.113556.1.4.803:=32)(!(IsCriticalSystemObject=TRUE)))" -SearchBase "$domainDN" | where { $_.useraccountcontrol -eq 544 }
$numberOfResults = $query.count
# Output pwnotreq users in grid view
#Get-ADUser -Properties Name,distinguishedname,useraccountcontrol,objectClass -LDAPFilter "(&(userAccountControl:1.2.840.113556.1.4.803:=32)(!(IsCriticalSystemObject=TRUE)))" -SearchBase "$domainDN" | select SamAccountName,Name,useraccountcontrol,distinguishedname | Out-GridView﻿
$query | select SamAccountName,Name,useraccountcontrol,distinguishedname >C:\temp\nopasswdaccounts\PwNotReq.txt
echo
