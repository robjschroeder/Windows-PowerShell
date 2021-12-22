get-childitem "C:\Users\username\Desktop\Silverlight\*" *.bat |  
Foreach-Object {copy-item $_.fullname -destination C:\Users\username\Desktop\Archived}