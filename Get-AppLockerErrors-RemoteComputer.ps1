$computersTXTpath = "C:\scripts\windows powershell\work\applocker\Computers.txt"
$computers = Get-Content -Path $computersTXTpath 

ForEach ($computer in $computers)
    {

        Get-WinEvent -LogName "Microsoft-Windows-AppLocker/EXE and DLL" -ComputerName $computer | Where { $_.ID -eq 8004 }

    }