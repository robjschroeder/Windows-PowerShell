$path = 'OU=OU,OU=server,OU=domain,OU=com'

$Computers = Get-Content 'C:\Scripts\Windows PowerShell\Work\ADComputers.txt'

foreach ($Computer in $Computers)
    {

        New-ADComputer -Name $Computer -path $path -Credential $cred -Enabled $true -Verbose

    }