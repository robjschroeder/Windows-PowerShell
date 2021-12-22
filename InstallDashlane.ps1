$temp = "C:\temp"
New-Item $temp\DashlaneStart.txt -ItemType file
Invoke-WebRequest -Uri 'https://d3qm0vl2sdkrc.cloudfront.net/releases/6.1901.0/6.1901.0.16461/release/DashlaneInst.exe' -OutFile $temp\DashlaneInst.exe
Start-Process -Wait -FilePath $temp\DashlaneInst.exe -ArgumentList "/SD" -PassThru -NoNewWindow

