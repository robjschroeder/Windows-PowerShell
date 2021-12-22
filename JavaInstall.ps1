#Variable passed through Kaseya i.e. "8u171"
param (
    [Parameter(Mandatory = $true)]
    [string]$ver
)
#UPDATE Server Address
$server = "\\server.domain.com\JAVA"

#Get Java version(s) installed 
$java = Get-WmiObject -Class win32_product -Filter "Name like '%Java%Update %'" | ForEach-Object {$_.Name} 
$java | ForEach-Object { Write-Host " : Found -->    $_" -ForegroundColor Yellow}
 
gwmi Win32_Product -filter "name like 'Java%' AND vendor like 'Oracle%'" | % { $_.Uninstall() }
 
#Create the temp directory and copy file 
if ((gwmi win32_operatingsystem | select osarchitecture).osarchitecture -eq "64-bit")
{
    #64 bit logic here
    Copy-Item -Path "$server\v$ver\jre-$ver-x64.msi" -Destination "C:\temp\" -Force 
 
            #Install the application 
            Write-Host "Installing   Java 8 Update" -foregroundcolor White 
            $product= [WMICLASS]"\\$env:computername\ROOT\CIMV2:win32_Product" 
            $product.Install("c:\temp\jre-$ver-x64.msi") | Out-Null        
      
            #Query new Java version(s) 
            $newJava = Get-WmiObject -Class Win32_Product -Filter "Name like '%Java%'" | Foreach-Object {$_.Name} 
            $newJava | Foreach-Object {Write-Host "New Java is  $_" -foregroundcolor Green}  

            #Remove installer from temp folder
            Remove-Item -Path C:\temp\jre-$ver-x64.msi -Force
}
else
{
    Copy-Item -Path "$server\v$ver\jre-$ver.msi" -Destination "C:\temp\" -Force 
 
            #Install the application 
            Write-Host "Installing   Java 8 Update" -foregroundcolor White 
            $product= [WMICLASS]"\\$env:computername\ROOT\CIMV2:win32_Product" 
            $product.Install("c:\temp\jre-$ver.msi") | Out-Null        
      
            #Query new Java version(s) 
            $newJava = Get-WmiObject -Class Win32_Product -ComputerName -Filter "Name like '%Java%'" | Foreach-Object {$_.Name} 
            $newJava | Foreach-Object {Write-Host "New Java is  $_" -foregroundcolor Green}

            #Remove installer from temp folder
            Remove-Item -Path C:\temp\jre-$ver.msi -Force
}
Exit