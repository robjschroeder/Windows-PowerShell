# Import the Group Policy module 
Import-Module GroupPolicy 

### Set global variables 

# To find the formatting/syntax for the OUs you want, open Active Directory Users and Computers, then
# right-click on an OU, choose "Attribute Editor", "DistinguishedName", click "view", then copy + paste
# in to the source and target fields for both OUs you want to use

# Source for GPO links 
$Source = "OU=OU,DC=server,DC=domain,DC=com" 
# Target where we want to set the new links 
$Target = "OU=DestinationOU,DC=server,DC=domain,DC=com" 

### Finished setting global variables 

# Get the linked GPOs 
$linked = (Get-GPInheritance -Target $source).gpolinks 

# Loop through each GPO and link it to the target 
foreach ($link in $linked) 
{ 
    $guid = $link.GPOId 
    $order = $link.Order 
    $enabled = $link.Enabled 
    if ($enabled) 
    { 
        $enabled = "Yes" 
    } 
    else 
    { 
        $enabled = "No" 
    } 
    # Create the link on the target 
    New-GPLink -Guid $guid -Target $Target -LinkEnabled $enabled -confirm:$false 
    # Set the link order on the target 
    Set-GPLink -Guid $guid -Target $Target -Order $order -confirm:$false 
}