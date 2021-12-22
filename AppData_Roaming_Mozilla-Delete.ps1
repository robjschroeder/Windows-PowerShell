$Users = get-childitem -Path C:\Users

foreach ($user in $users)
{  
    if (test-path -path "C:\users\$user\appdata\roaming\mozilla")
        {
            write-host "C:\users\$user\appdata\roaming\mozilla" does exist, deleting now
            remove-item -Path "C:\Users\$user\appdata\roaming\mozilla" -recurse 
        }
    else
        {
            write-host "C:\users\$user\appdata\roaming\mozilla" does not exist
        }
}