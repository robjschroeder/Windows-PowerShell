Function Connect-Exchange {

    param(
        [Parameter( Mandatory=$false)]
        [string]$URL="mailhub.server.domain.com"
    )

    $Credential = Get-Credential -Message "Enter your Exchange admin Credentials"

    $PSSessionLine = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$URL/PowerShell/ -Authentication Kerberos -Credential $Credential

    Import-PSSession $PSSessionLine

}

Connect-Exchange