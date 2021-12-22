#The GpoLinks property of the SOM object contains a list of all the GPO links for the OU. Each object in this list is of type Microsoft.GroupPolicy.GpoLink. 
#The following shows one such object:
#GpoId : d02126d4-82e8-4e87-b4a0-2d44b6891411
#DisplayName : TestGPO-3
#Enabled : True
#Enforced : False
#Target : ou=myou,dc=cso,dc=com
#Order : 1

#========================
Import-Module GroupPolicy
$importlist = import-csv -Path "c:\scripts\windows powershell\work\gplink.csv" | foreach {
    $source = $importlist.source
    $target = $importlist.target
    $linked = (Get-GPInheritance -Target $source).GpoLinks
    $BI = (Get-GPInheritance -Target $source).GPOInheritanceBlocked
    If ($BI)    
        { 
            $BI = "Yes"
            Set-GPInheritance -Target $target -IsBlocked $BI -Verbose
        }
        Else
        {
            $BI = "No"
        }
        foreach ($link in $linked)
            {
                $guid = $link.GpoId
                $order = $link.Order
                $enabled = $link.Enabled
                $enforced = $link.Enforced   
                If ($enabled)
                {
                    $enabled = "Yes"
                }
                else
                {
                    $enabled = "No"
                }
                If ($enforced)
                {
                    $enforced = "Yes"
                }
                else
                {
                    $enforced = "No"
                }
                New-GPLink -Guid $guid -Target $target -LinkEnabled $enabled -Verbose
                Set-GPLink -Guid $guid -Target $target -Order $order -LinkEnabled $enabled -Enforced $enforced -Verbose
                    }
        }