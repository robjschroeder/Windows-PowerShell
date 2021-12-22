$computer = gc env:computername
#Update Product Key
$key = "KEY"

$service = get-wmiObject -query "select * from SoftwareLicensingService" -computername $computer

$service.InstallProductKey($key)

$service.RefreshLicenseStatus()