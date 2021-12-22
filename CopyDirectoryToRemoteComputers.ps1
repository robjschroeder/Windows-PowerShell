$SearchString = Read-Host "Please enter a computer name or building/room number"
$Computers = (Get-ADComputer -LDAPFilter "(name=*$searchString*)").name

foreach ($computer in $computers)
    {
        Copy-Item -Path 'C:\Users\username\Desktop\Folder' -Destination "\\$computer\c$\Users\Public\Desktop" -Recurse
    }