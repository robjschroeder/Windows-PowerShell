Import-Module ActiveDirectory
#$credential = Get-Credential -Message "Enter your AD admin credentials"
$today = (Get-Date)
$yearago = $today.AddMonths(-12)

(Get-ADForest).domains | % {
Get-ADUser -filter {samaccountname -like '*-*' -and samaccountname -notlike '*admin*' -and samaccountname -notlike '*test*'} -Properties * -SearchBase "$((Get-ADDomain).DistinguishedName)" | Select Name,sAMAccountName,PasswordLastSet,LastLogonDate | Export-Csv -Path "C:\temp\MultiUseAccounts.csv"
}