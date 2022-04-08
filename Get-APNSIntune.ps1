# Import Modules
if( -not (Get-Module Microsoft.Graph.Intune -ListAvailable)){
    # Microsoft Graph Intune module not installed, installing now...
    Install-Module Microsoft.Graph.Intune
}
if ( -not (Get-Module az.accounts -ListAvailable)){
    # Az.Accounts module not installed, installing now...
    Install-Module az.accounts
}

# Variables
# Get Bearer Token from MSGraph
$token=(Get-AzAccessToken -ResourceTypeName MSGraph).Token

# Set headers for web request
$headers=@{}
$headers.Add("Accept", "application/json")
$headers.Add("Authorization", "Bearer $token")

# Get information on Apple Push Notifiation certifiate
$response = Invoke-WebRequest -Uri 'https://graph.microsoft.com/v1.0/deviceManagement/applePushNotificationCertificate' -Method GET -Headers $headers 
