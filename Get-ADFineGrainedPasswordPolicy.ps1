Import-Module activedirectory
Get-ADFineGrainedPasswordPolicy -Filter {Name -like "*"} | FT Name, Precedence,MaxPasswordAge,MinPasswordLength -A