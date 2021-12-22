#Update path to computers.csv ex. C:\scripts\windows powershell\Work\ADComputers.csv
$computers = Get-Content -Path "..."

#OU to create the new computers ex. OU=OU,DC=Server,DC=Domain,DC=Com
$OU = '...'

#Update your computers' descriptions ex. ITN - Dell
$description = "..."

#Update your DC Server Name ex. DC-Name
$server = '...'

ForEach ($computer in $computers)
    {
        New-ADComputer -name $computer -Path $OU -Description $description -Server $server -verbose
    }
