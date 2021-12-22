# Source for GPO links
$Source = read-host "Please enter the OU you want to copy the GPO links from"
# Target where we want to set the new links
$Target = read-host "Please enter the OU you want to copy the GPO links to"

### Finished setting global variables

# Get the linked GPOs
$linked = (Get-GPInheritance -Target $source).inheritedgpolinks

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