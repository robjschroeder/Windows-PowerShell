Import-Module ActiveDirectory
#$credential = Get-Credential -Message "Enter your AD admin credentials"

(Get-ADForest).domains | % {
(Get-ADComputer -filter * -SearchBase "$((Get-ADDomain).DistinguishedName)").count
}