$users = Get-ChildItem C:\Users | ?{ $_.PSIsContainer }
foreach ($user in $users){
    $dashlanepath = "C:\Users\$user\AppData\Roaming\Dashlane"
    If(Test-Path $dashlanepath){
        New-Item -Path C:\Temp\ -Name "DashlaneAppDataExists.txt" -ItemType "File" -Value "Dashlane exists in a Users' AppData"
    }
   }