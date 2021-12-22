<#
Update-AdobeFlashPlayer.ps1
Requires a working Internet connection for downloading a list of the most recent 
Flash version numbers. 
Also requires a working Internet connection for downloading a Flash uninstaller and a 
complete Flash installer(s) from Adobe (but this procedure is not initiated, if the 
system is deemed up-to-date).
During the optional update phase requires to be run in an elevated PowerShell window 
(where PowerShell has been started with the 'run as an administrator' option). The 
elevated rights are needed for uninstalling Flash, installing Flash and for writing 
the mms.cfg file.
Please also notice that during the actual update phase Update-AdobeFlashPlayer 
closes a bunch of processes without any further notice in Step 3 and in Step 6 
Update-AdobeFlashPlayer alters the Flash configuration file (mms.cfg) so, that for 
instance, the automatic Flash updates are turned off.
If a working Internet connection is not found, Update-AdobeFlashPlayer will exit at 
an early stage without displaying any info apart from what is found on the system. If 
Update-AdobeFlashPlayer is run without elevated rights (but with a working Internet 
connection), it will be shown, whether a Flash update is needed or not, but the script 
will exit before actually downloading any files or making any changes to the system.
The Flash Player ActiveX control on Windows 8.1 and above is a component of Internet 
Explorer and Edge and is updated via Windows Update. By using the Flash Player 
ActiveX installer, Flash Player ActiveX control cannot be installed on Windows 8.1 
and above systems. Also, the Flash Player uninstaller doesn't uninstall the ActiveX 
control on Windows 8.1 and above systems.
For further info, for instance a command
help ./Update-AdobeFlashPlayer -Full
may be used at the PowerShell prompt window [PS>] in the folder, where the script is placed.
https://forums.adobe.com/thread/2208103
Alternatively, if you just want a notification when security updates become available 
(and with a continuous, sustained investment in security hardening, that's pretty much every release), 
you can subscribe to the Adobe Security Notification Service, 
which sends out email alerts when security updates become available for our products.
https://forums.adobe.com/thread/2208103
Adobe Security Notification E-Mail Service Subscription Page:
https://campaign.adobe.com/webApp/adbeSecurityNotificationsRegistration?id=0
Adobe Flash Player Master Version XML file:
http://fpdownload.macromedia.com/pub/flashplayer/masterversion/masterversion.xml
Adobe Flash Player Administration Guide: 
https://www.adobe.com/devnet/flashplayer/articles/flash_player_admin_guide.html
#>




$path = $env:temp
$computer = $env:COMPUTERNAME
$ErrorActionPreference = "Stop"
$start_time = Get-Date
$empty_line = ""


# Determine the architecture of a machine                                                     # Credit: Tobias Weltner: "PowerTips Monthly vol 8 January 2014"
If ([IntPtr]::Size -eq 8) {
    $empty_line | Out-String
    "Running in a 64-bit subsystem" | Out-String
    $64 = $true
    $bit_number = "64"
    $registry_paths = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $empty_line | Out-String
} Else {
    $empty_line | Out-String
    "Running in a 32-bit subsystem" | Out-String
    $64 = $false
    $bit_number = "32"
    $registry_paths = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )    
    $empty_line | Out-String
} # else


# Function to check whether a program is installed or not                                     # Credit: chocolatey: "Flash Player Plugin"
Function Check-InstalledSoftware ($display_name, $display_version) {
    Return Get-ItemProperty $registry_paths -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -eq $display_name -and $_.DisplayVersion -eq $display_version }
} # function


# Try to find out which Flash versions, if any, are installed on the system
# Source: "Adobe Flash Player Administration Guide": http://www.adobe.com/devnet/flashplayer/articles/flash_player_admin_guide.html

<#
            ### .msi installed ActiveX for IE
            ### Note: Get-WmiObject -Class Win32_Product is very slow to run...
            $activex_already_installed = $false
            $activex_major_version = ([version]$xml_activex_win_current).Major
            If (Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq "Adobe Flash Player $activex_major_version ActiveX" -and $_.Version -eq $xml_activex_win_current }) {
                $activex_already_installed = $true
                $activex_already_text = "The most recent version of Adobe Flash Player ActiveX for IE $activex_version is already installed."
                Write-Output $activex_already_text
            } Else {
                $continue = $true
            } # else
#>

# .exe or .msi installed ActiveX for IE
# The player is an OCX file whose name reflects the version number.
$activex_is_installed = $false
If ((Test-Path $env:windir\System32\Macromed\Flash\Flash32*.ocx) -eq $true) {
    # For example, Flash32_11_2_202_228.ocx (32-bit Windows)
    $activex_is_installed = $true
    $activex_32_bit_file = Get-ChildItem $env:windir\System32\Macromed\Flash\Flash32*.ocx -ErrorAction Stop
    $activex_32_bit_version = ((Get-Item $activex_32_bit_file | Select-Object -ExpandProperty VersionInfo).ProductVersion).replace(",",".")
    } If ((Test-Path $env:windir\System32\Macromed\Flash\Flash64*.ocx) -eq $true) {
        # For example, Flash64_11_2_202_228.ocx (64-bit Windows)
        $activex_is_installed = $true
        $activex_64_bit_file = Get-ChildItem $env:windir\System32\Macromed\Flash\Flash64*.ocx -ErrorAction Stop
        $activex_64_bit_version = ((Get-Item $activex_64_bit_file | Select-Object -ExpandProperty VersionInfo).ProductVersion).replace(",",".")
        } If ((Test-Path $env:windir\SysWow64\Macromed\Flash\Flash*.ocx) -eq $true) {
            # For example, Flash32_11_2_202_228.ocx (32-bit Windows)
            $activex_is_installed = $true
            $activex_64_bit_in_32_bit_mode_file = Get-ChildItem $env:windir\SysWow64\Macromed\Flash\Flash*.ocx -ErrorAction Stop
            $activex_64_bit_in_32_bit_mode_version = ((Get-Item $activex_64_bit_in_32_bit_mode_file | Select-Object -ExpandProperty VersionInfo).ProductVersion).replace(",",".")
} Else {
    $continue = $true
} # else




# .msi installed Firefox Plugin (NPAPI)

# .exe or .msi installed Firefox Plugin (NPAPI)
# On Windows, files named NPSWF32.dll (NPSWF64.dll for 64-bit Windows) and flashplayer.xpt are installed, and for Flash Player 11.2 and later, the dll file name also includes the build number.
$plugin_is_installed = $false
If ((Test-Path $env:windir\System32\Macromed\Flash\NPSWF32*.dll) -eq $true) {
    # For example, NPSWF32_11_2_202_228.dll (32-bit Windows)
    $plugin_is_installed = $true
    $plugin_32_bit_file = Get-ChildItem $env:windir\System32\Macromed\Flash\NPSWF32*.dll -ErrorAction Stop
    $plugin_32_bit_version = ((Get-Item $plugin_32_bit_file | Select-Object -ExpandProperty VersionInfo).ProductVersion).replace(",",".")
    } If ((Test-Path $env:windir\System32\Macromed\Flash\NPSWF64*.dll) -eq $true) {
        # For example, NPSWF64_11_2_202_228.dll (64-bit Windows)
        $plugin_is_installed = $true
        $plugin_64_bit_file = Get-ChildItem $env:windir\System32\Macromed\Flash\NPSWF64*.dll -ErrorAction Stop
        $plugin_64_bit_version = ((Get-Item $plugin_64_bit_file | Select-Object -ExpandProperty VersionInfo).ProductVersion).replace(",",".")
        } If ((Test-Path $env:windir\SysWow64\Macromed\Flash\NPSWF*.dll) -eq $true) {
            # For example, NPSWF32_11_2_202_228.dll (32-bit Windows)
            $plugin_is_installed = $true
            $plugin_64_bit_in_32_bit_mode_file = Get-ChildItem $env:windir\SysWow64\Macromed\Flash\NPSWF*.dll -ErrorAction Stop
            $plugin_64_bit_in_32_bit_mode_version = ((Get-Item $plugin_64_bit_in_32_bit_mode_file | Select-Object -ExpandProperty VersionInfo).ProductVersion).replace(",",".")
} Else {
    $continue = $true
} # else




# .msi installed pepper Opera and Chromium-based browsers (PPAPI)

# .exe or .msi installed pepper Opera and Chromium-based browsers (PPAPI)
# On Windows, files named pepflashplayer32.dll (pepflashplayer64.dll for 64-bit Windows) and manifest.json are installed. The dll file name also includes the build number.
$pepper_is_installed = $false
If ((Test-Path $env:windir\System32\Macromed\Flash\pepflashplayer32*.dll) -eq $true) {
    # For example, pepflashplayer32_22_0_0_157.dll (32-bit Windows)
    $pepper_is_installed = $true
    $pepper_32_bit_file = Get-ChildItem $env:windir\System32\Macromed\Flash\pepflashplayer32*.dll -ErrorAction Stop
    $pepper_32_bit_version = ((Get-Item $pepper_32_bit_file | Select-Object -ExpandProperty VersionInfo).ProductVersion).replace(",",".")
    } If ((Test-Path $env:windir\System32\Macromed\Flash\pepflashplayer64*.dll) -eq $true) {
        # For example, pepflashplayer64_22_0_0_157.dll (64-bit Windows)
        $pepper_is_installed = $true
        $pepper_64_bit_file = Get-ChildItem $env:windir\System32\Macromed\Flash\pepflashplayer64*.dll -ErrorAction Stop
        $pepper_64_bit_version = ((Get-Item $pepper_64_bit_file | Select-Object -ExpandProperty VersionInfo).ProductVersion).replace(",",".")
        } If ((Test-Path $env:windir\SysWow64\Macromed\Flash\pepflashplayer*.dll) -eq $true) {
            # For example, pepflashplayer32_22_0_0_157.dll (32-bit Windows)
            $pepper_is_installed = $true
            $pepper_64_bit_in_32_bit_mode_file = Get-ChildItem $env:windir\SysWow64\Macromed\Flash\pepflashplayer*.dll -ErrorAction Stop
            $pepper_64_bit_in_32_bit_mode_version = ((Get-Item $pepper_64_bit_in_32_bit_mode_file | Select-Object -ExpandProperty VersionInfo).ProductVersion).replace(",",".")
} Else {
    $continue = $true
} # else


        $obj_existing += New-Object -TypeName PSCustomObject -Property @{
            'Windows Internet Explorer (ActiveX) Flash Player is installed?'                    = $activex_is_installed
            'Windows Firefox (NPAPI) Flash Player is installed?'                                = $plugin_is_installed
            'Windows Opera and Chromium-based browsers (PPAPI) Flash Player is installed?'      = $pepper_is_installed
            'Internet Explorer (ActiveX) Flash Player (32-bit)'                                 = $activex_32_bit_version
            'Internet Explorer (ActiveX) Flash Player (64-bit)'                                 = $activex_64_bit_version
            'Internet Explorer (ActiveX) Flash Player (64-bit in 32-bit mode)'                  = $activex_64_bit_in_32_bit_mode_version
            'Firefox (NPAPI) Flash Player (32-bit)'                                             = $plugin_32_bit_version
            'Firefox (NPAPI) Flash Player (64-bit)'                                             = $plugin_64_bit_version
            'Firefox (NPAPI) Flash Player (64-bit in 32-bit mode)'                              = $plugin_64_bit_in_32_bit_mode_version
            'Opera and Chromium-based browsers (PPAPI) Flash Player (32-bit)'                   = $pepper_32_bit_version
            'Opera and Chromium-based browsers (PPAPI) Flash Player (64-bit)'                   = $pepper_64_bit_version
            'Opera and Chromium-based browsers (PPAPI) Flash Player (64-bit in 32-bit mode)'    = $pepper_64_bit_in_32_bit_mode_version
        } # New-Object
    $obj_existing.PSObject.TypeNames.Insert(0,"Previously Installed (Existing) Flash Player Versions Found on the System")
    $obj_existing_selection = $obj_existing | Select-Object 'Windows Internet Explorer (ActiveX) Flash Player is installed?','Windows Firefox (NPAPI) Flash Player is installed?','Windows Opera and Chromium-based browsers (PPAPI) Flash Player is installed?','Internet Explorer (ActiveX) Flash Player (32-bit)','Internet Explorer (ActiveX) Flash Player (64-bit)','Internet Explorer (ActiveX) Flash Player (64-bit in 32-bit mode)','Firefox (NPAPI) Flash Player (32-bit)','Firefox (NPAPI) Flash Player (64-bit)','Firefox (NPAPI) Flash Player (64-bit in 32-bit mode)','Opera and Chromium-based browsers (PPAPI) Flash Player (32-bit)','Opera and Chromium-based browsers (PPAPI) Flash Player (64-bit)','Opera and Chromium-based browsers (PPAPI) Flash Player (64-bit in 32-bit mode)'


    # Display the previously installed (existing) Flash version numbers in console
    $header_existing = "Previously Installed (Existing) Flash Player Versions Found on the System"
    $coline_existing = "-------------------------------------------------------------------------"
    Write-Output $header_existing
    $coline_existing | Out-String
    Write-Output $obj_existing_selection
    $empty_line | Out-String




# Determine the original installed Flash version numbers regardles whether the system is 32- or 64-bits.
If ($activex_64_bit_in_32_bit_mode_version -ne $null) { $activex_baseline = $activex_64_bit_in_32_bit_mode_version } Else { $continue = $true }
If ($activex_32_bit_version -ne $null)                { $activex_baseline = $activex_32_bit_version }                Else { $continue = $true }
If ($activex_64_bit_version -ne $null)                { $activex_baseline = $activex_64_bit_version }                Else { $continue = $true }


If ($plugin_64_bit_in_32_bit_mode_version -ne $null)  { $plugin_baseline = $plugin_64_bit_in_32_bit_mode_version }   Else { $continue = $true }
If ($plugin_32_bit_version -ne $null)                 { $plugin_baseline = $plugin_32_bit_version }                  Else { $continue = $true }
If ($plugin_64_bit_version -ne $null)                 { $plugin_baseline = $plugin_64_bit_version }                  Else { $continue = $true }

If ($pepper_64_bit_in_32_bit_mode_version -ne $null)  { $pepper_baseline = $pepper_64_bit_in_32_bit_mode_version }   Else { $continue = $true }
If ($pepper_32_bit_version -ne $null)                 { $pepper_baseline = $pepper_32_bit_version }                  Else { $continue = $true }
If ($pepper_64_bit_version -ne $null)                 { $pepper_baseline = $pepper_64_bit_version }                  Else { $continue = $true }




# Check if the computer is connected to the Internet                                          # Credit: ps1: "Test Internet connection"
If (([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet) -eq $false) {
    $empty_line | Out-String
    Return "The Internet connection doesn't seem to be working. Exiting without checking the latest Flash version numbers or without updating Flash."
} Else {
    Write-Verbose 'Checking the most recent Flash version numbers from the Flash website...'    
} # else




# Check the most recent Flash version numbers by connecting to the Flash website
# Source: "Adobe Flash Player Administration Guide": http://www.adobe.com/devnet/flashplayer/articles/flash_player_admin_guide.html
$xml_url = "https://fpdownload.macromedia.com/pub/flashplayer/masterversion/masterversion.xml"

try
{
    $xml_versions = New-Object XML
    $xml_versions.Load($xml_url)
}
catch [System.Net.WebException]
{
    Write-Warning "Failed to access $xml_url"
    $empty_line | Out-String
    $xml_text = "Please consider running this script again. Sometimes the XML-file just isn't queryable for no apparent reason. The success rate 'in the second go' usually seems to be a bit higher."
    Write-Output $xml_text
    $empty_line | Out-String
    Return "Exiting without checking the latest Flash version numbers or without updating Flash."
}

    $xml_activex_win8_current = ($xml_versions.version.release.ActiveX_win8.version).replace(",",".")
    $xml_activex_win10_current = ($xml_versions.version.release.ActiveX_win10.version).replace(",",".")
    $xml_activex_edge_current = ($xml_versions.version.release.ActiveX_Edge.version).replace(",",".")
    $xml_activex_win_current = ($xml_versions.version.release.ActiveX_win.version).replace(",",".")
    $xml_plugin_win_current = ($xml_versions.version.release.NPAPI_win.version).replace(",",".")
    $xml_plugin_mac_current = ($xml_versions.version.release.NPAPI_mac.version).replace(",",".")
    $xml_plugin_linux_current = ($xml_versions.version.release.NPAPI_linux.version).replace(",",".")
    $xml_ppapi_win_current = ($xml_versions.version.release.PPAPI_win.version).replace(",",".")
    $xml_ppapi_winchrome_current = ($xml_versions.version.release.PPAPI_winchrome.version).replace(",",".")
    $xml_ppapi_mac_current = ($xml_versions.version.release.PPAPI_mac.version).replace(",",".")
    $xml_ppapi_macchrome_current = ($xml_versions.version.release.PPAPI_macchrome.version).replace(",",".")
    $xml_ppapi_linux_current = ($xml_versions.version.release.PPAPI_linux.version).replace(",",".")
    $xml_ppapi_linuxchrome_current = ($xml_versions.version.release.PPAPI_linuxchrome.version).replace(",",".")
    $xml_ppapi_chromeos_current = ($xml_versions.version.release.PPAPI_chromeos.version).replace(",",".")

 #   $xml_activex_win_extended = ($xml_versions.version.esr.ActiveX_win.version).replace(",",".")
 #   $xml_plugin_win_extended = ($xml_versions.version.esr.NPAPI_win.version).replace(",",".")
 #   $xml_plugin_mac_extended = ($xml_versions.version.esr.NPAPI_mac.version).replace(",",".")


        $obj_most_recent += New-Object -TypeName PSCustomObject -Property @{
            'Windows Internet Explorer (ActiveX)'                               = $xml_activex_win_current
            'Windows Internet Explorer, embedded Windows 8.1 (ActiveX)'         = [string]$xml_activex_win8_current + ' (updateable via Windows Update)'
            'Windows Edge, embedded Windows 10 (ActiveX)'                       = [string]$xml_activex_edge_current + ' (updateable via Windows Update)'
            'Windows Firefox (NPAPI)'                                           = $xml_plugin_win_current
            'Windows Chrome, embedded (PPAPI)'                                  = $xml_ppapi_winchrome_current
            'Windows Opera and Chromium-based browsers (PPAPI)'                 = $xml_ppapi_win_current
            'Macintosh OS X Firefox and Safari (NPAPI)'                         = $xml_plugin_mac_current
            'Macintosh OS X Chrome, embedded (PPAPI)'                           = $xml_ppapi_macchrome_current
            'Macintosh OS X Opera and Chromium-based browsers (PPAPI)'          = $xml_ppapi_mac_current
            'Linux Chrome, embedded (PPAPI)'                                    = $xml_ppapi_linuxchrome_current
            'Linux Chromium-based browsers (PPAPI)'                             = $xml_ppapi_linux_current
            'ChromeOS (PPAPI)'                                                  = $xml_ppapi_chromeos_current
        } # New-Object
    $obj_most_recent.PSObject.TypeNames.Insert(0,"Most Recent non-beta Flash Player Versions Available")
    $obj_most_recent_selection = $obj_most_recent | Select-Object 'Windows Internet Explorer (ActiveX)','Windows Internet Explorer, embedded Windows 8.1 (ActiveX)','Windows Edge, embedded Windows 10 (ActiveX)','Windows Firefox (NPAPI)','Windows Chrome, embedded (PPAPI)','Windows Opera and Chromium-based browsers (PPAPI)','Macintosh OS X Firefox and Safari (NPAPI)','Macintosh OS X Chrome, embedded (PPAPI)','Macintosh OS X Opera and Chromium-based browsers (PPAPI)','Linux Chrome, embedded (PPAPI)','Linux Chromium-based browsers (PPAPI)','ChromeOS (PPAPI)'


        $obj_extended_support += New-Object -TypeName PSCustomObject -Property @{
            'Extended Support Release Windows Internet Explorer (ActiveX) Flash version'            = $xml_activex_win_extended
            'Extended Support Release Windows Firefox (NPAPI) Flash version'                        = $xml_plugin_win_extended
            'Extended Support Release Macintosh OS X Firefox and Safari (NPAPI) Flash version'      = $xml_plugin_mac_extended
            'Extended Support Release Linux Firefox (NPAPI) Flash version'                          = $xml_plugin_linux_current
        } # New-Object
    $obj_extended_support.PSObject.TypeNames.Insert(0,"Extended Support Release Flash Player Versions")
    $obj_extended_support_selection = $obj_extended_support | Select-Object 'Extended Support Release Windows Internet Explorer (ActiveX) Flash version','Extended Support Release Windows Firefox (NPAPI) Flash version','Extended Support Release Macintosh OS X Firefox and Safari (NPAPI) Flash version','Extended Support Release Linux Firefox (NPAPI) Flash version'


    # Display the most recent and extended support Flash version numbers in console
    $header_most_recent = "Most Recent non-beta Flash Player Versions Available"
    $coline_most_recent = "----------------------------------------------------"
    Write-Output $header_most_recent
    $coline_most_recent | Out-String
    Write-Output $obj_most_recent_selection
    $empty_line | Out-String
    $header_extended = "Extended Support Release Flash Player Versions"
    $coline_extended = "----------------------------------------------"
    Write-Output $header_extended
    $coline_extended | Out-String
    $obj_extended_support_selection
    $empty_line | Out-String




# Try to determine which Flash versions, if any, are outdated and need to be updated.
$most_recent_activex_major_version = ([version]$xml_activex_win_current).Major
$most_recent_plugin_major_version = ([version]$xml_plugin_win_current).Major    
$most_recent_pepper_major_version = ([version]$xml_ppapi_win_current).Major    

$downloading_activex_is_required = $false
$activex_exception = $false
If ($activex_is_installed -eq $true) {
    $most_recent_activex_already_exists = Check-InstalledSoftware "Adobe Flash Player $most_recent_activex_major_version ActiveX" $xml_activex_win_current
    If ([System.Environment]::OSVersion.Version -lt '6.2') {
        If ($most_recent_activex_already_exists) {
            Write-Output "Currently (until the next Flash Player version is released) Adobe Flash Player for Internet Explorer (ActiveX) v$activex_baseline doesn't need any further maintenance or care."
            $empty_line | Out-String
        } Else {
            $downloading_activex_is_required = $true
            Write-Warning "Adobe Flash Player for Internet Explorer (ActiveX) v$activex_baseline seems to be outdated."
            $empty_line | Out-String
            Write-Output "The most recent non-beta Flash version of ActiveX is v$xml_activex_win_current. The installed ActiveX Flash version v$activex_baseline needs to be updated."
            $empty_line | Out-String
        } # else

    } ElseIf ([System.Environment]::OSVersion.Version -ge '6.2') {
        If ($xml_activex_win_current -eq $activex_baseline) {
            Write-Output "Currently (until the next Flash Player version is released) the ActiveX Adobe Flash Player for Internet Explorer and/or for Edge v$activex_baseline doesn't need any further maintenance or care."
            $empty_line | Out-String
        } Else {
            $downloading_activex_is_required = $false
            $activex_exception = $true
            Write-Warning "Please use Windows Update to update Adobe Flash Player(s) for Internet Explorer (ActiveX) and/or for Edge (ActiveX)."
            $empty_line | Out-String
            Write-Output "Adobe Flash Player for Internet Explorer (ActiveX) v$activex_baseline seems to be outdated. The most recent non-beta Flash version of ActiveX is v$xml_activex_win_current. The installed ActiveX Flash version v$activex_baseline needs to be updated. However, the Flash Player ActiveX control on Windows 8.1 and above is a component of Internet Explorer and Edge and is updated via Windows Update. By using the standalone Flash Player ActiveX installer, Flash Player ActiveX control cannot be installed on Windows 8.1 and above systems. Also, the Flash Player uninstaller doesn't uninstall the ActiveX control on Windows 8.1 and above systems. For updating the ActiveX Flash Player on Windows 8.1 and above systems, please use the Windows Update."
            $empty_line | Out-String
        } # else

    } Else {
        $continue = $true
    } # else

} Else {
    $continue = $true
} # else


$downloading_plugin_is_required = $false
If ($plugin_is_installed -eq $true) {
    $most_recent_plugin_already_exists = Check-InstalledSoftware "Adobe Flash Player $most_recent_plugin_major_version NPAPI" $xml_plugin_win_current
    If ($most_recent_plugin_already_exists) {
        Write-Output "Currently (until the next Flash Player version is released) Adobe Flash Player for Firefox (NPAPI) v$plugin_baseline doesn't need any further maintenance or care."
        $empty_line | Out-String
    } Else {
        $downloading_plugin_is_required = $true
        Write-Warning "Adobe Flash Player for Firefox (NPAPI) v$plugin_baseline seems to be outdated."
        $empty_line | Out-String
        Write-Output "The most recent non-beta Flash version of NPAPI is v$xml_plugin_win_current. The installed NPAPI Flash version v$plugin_baseline needs to be updated."
        $empty_line | Out-String
    } # else

} Else {
    $continue = $true
} # else


$downloading_pepper_is_required = $false
If ($pepper_is_installed -eq $true) {
    $most_recent_pepper_already_exists = Check-InstalledSoftware "Adobe Flash Player $most_recent_pepper_major_version PPAPI" $xml_ppapi_win_current
    If ($most_recent_pepper_already_exists) {
        Write-Output "Currently (until the next Flash Player version is released) Adobe Flash Player for Opera and Chromium-based browsers (PPAPI) v$pepper_baseline doesn't need any further maintenance or care."
        $empty_line | Out-String
    } Else {
        $downloading_pepper_is_required = $true
        Write-Warning "Adobe Flash Player for Opera and Chromium-based browsers (PPAPI) v$pepper_baseline seems to be outdated."
        $empty_line | Out-String
        Write-Output "The most recent non-beta Flash version of PPAPI is v$xml_ppapi_win_current. The installed PPAPI Flash version v$pepper_baseline needs to be updated."
        $empty_line | Out-String
    } # else

} Else {
    $continue = $true
} # else




        $obj_downloading += New-Object -TypeName PSCustomObject -Property @{
            'Adobe Flash Player for Internet Explorer (ActiveX)'                = If ($activex_exception -eq $true) { "True: Please use Windows Update to update Flash" } ElseIf ($activex_is_installed -eq $true) { $downloading_activex_is_required } Else { "-" }
            'Adobe Flash Player for Firefox (NPAPI)'                            = If ($plugin_is_installed -eq $true) { $downloading_plugin_is_required } Else { "-" }
            'Adobe Flash Player for Opera and Chromium-based browsers (PPAPI)'  = If ($pepper_is_installed -eq $true) { $downloading_pepper_is_required } Else { "-" }
        } # New-Object
    $obj_downloading.PSObject.TypeNames.Insert(0,"Maintenance Is Required for These Flash Versions")
    $obj_downloading_selection = $obj_downloading | Select-Object 'Adobe Flash Player for Internet Explorer (ActiveX)','Adobe Flash Player for Firefox (NPAPI)','Adobe Flash Player for Opera and Chromium-based browsers (PPAPI)'


    # Display in console which installers for Flash Player need to be downloaded
    $empty_line | Out-String
    $empty_line | Out-String
    $header_downloading = "Maintenance Is Required for the Following Flash Versions"
    $coline_downloading = "--------------------------------------------------------"
    Write-Output $header_downloading
    $coline_downloading | Out-String
    $obj_downloading_selection
    $empty_line | Out-String




# Determine if there is a real need to carry on with the rest of the script.
If (($activex_is_installed -eq $true) -or ($plugin_is_installed -eq $true) -or ($pepper_is_installed -eq $true)) {

    If (($downloading_activex_is_required -eq $false) -and ($downloading_plugin_is_required -eq $false) -and ($downloading_pepper_is_required -eq $false) -and ($activex_exception -eq $true)) {
        Return "Please use Windows Update to update the ActiveX-version of Adobe Flash Player."
    } ElseIf (($downloading_activex_is_required -eq $false) -and ($downloading_plugin_is_required -eq $false) -and ($downloading_pepper_is_required -eq $false)) {
        Return "The installed Flash seems to be OK."
    } Else {
        $continue = $true
    } # else
} Else {
    Write-Warning "No Flash (ActiveX, NPAPI or PPAPI) seems to be installed on the system."
    $empty_line | Out-String
    $no_flash_text_1 = "This script didn't detect that any of the three types of Flash Players mentioned above"
    $no_flash_text_2 = "would have been installed. Please consider installing the Flash Player by visiting"
    $no_flash_text_3 = "https://get.adobe.com/flashplayer/ or https://get.adobe.com/flashplayer/otherversions/"
    $no_flash_text_4 = "For full installation files please, for example, see the bottom of the page"
    $no_flash_text_5 = "https://helpx.adobe.com/flash-player/kb/installation-problems-flash-player-windows.html"
    $no_flash_text_6 = "and for the Adobe Flash uninstaller, please visit"
    $no_flash_text_7 = "https://helpx.adobe.com/flash-player/kb/uninstall-flash-player-windows.html"
    Write-Output $no_flash_text_1
    Write-Output $no_flash_text_2
    Write-Output $no_flash_text_3
    Write-Output $no_flash_text_4
    Write-Output $no_flash_text_5
    Write-Output $no_flash_text_6
    Write-Output $no_flash_text_7  

    # Offer the option to install a specific version of Flash, if no Flash is detected and the script is run in an elevated window
    # Source: "Adding a Simple Menu to a Windows PowerShell Script": https://technet.microsoft.com/en-us/library/ff730939.aspx
    # Credit: lamaar75: "Creating a Menu": http://powershell.com/cs/forums/t/9685.aspx
    # Credit: alejandro5042: "How to run exe with/without elevated privileges from PowerShell"
    If (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator") -eq $true) {
        $empty_line | Out-String
        Write-Verbose "Welcome to the Admin Corner." -verbose
        $admin_corner = $true
        $title_1 = "Install Flash (Step 1/2)"        
        $message_1 = "Would you like to install one of the Flash versions (ActiveX, NPAPI or PPAPI) with this script?"
        
        $yes = New-Object System.Management.Automation.Host.ChoiceDescription    "&Yes",    "Yes:     tries to download and install one of the Flash versions specified on the next step."
        $no = New-Object System.Management.Automation.Host.ChoiceDescription     "&No",     "No:      exits from this script (similar to Ctrl + C)."
        $exit = New-Object System.Management.Automation.Host.ChoiceDescription   "&Exit",   "Exit:    exits from this script (similar to Ctrl + C)."
        $abort = New-Object System.Management.Automation.Host.ChoiceDescription  "A&bort",  "Abort:   exits from this script (similar to Ctrl + C)."
        $cancel = New-Object System.Management.Automation.Host.ChoiceDescription "&Cancel", "Cancel:  exits from this script (similar to Ctrl + C)."

        $options_1 = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $exit, $abort, $cancel)
        $result_1 = $host.ui.PromptForChoice($title_1, $message_1, $options_1, 1) 

            switch ($result_1)
                {
                    0 {
                    "Yes. Proceeding to the next step.";
                    $continue = $true
                    }
                    1 {
                    "No. Exiting from Update-AdobeFlashPlayer script.";
                    Exit
                    }
                    2 {
                    "Exit. Exiting from Update-AdobeFlashPlayer script.";
                    Exit
                    }
                    3 {
                    "Abort. Exiting from Update-AdobeFlashPlayer script.";
                    Exit
                    }
                    4 {
                    "Cancel. Exiting from Update-AdobeFlashPlayer script.";
                    Exit
                    } # 4                           
                } # switch

        $empty_line | Out-String
        $title_2 = "Install Flash (Step 2/2)"
        $message_2 = "Which Flash version would you like to install?"

        $activex = New-Object System.Management.Automation.Host.ChoiceDescription "&ActiveX (pre Win 8.0)", "ActiveX: tries to download and install ActiveX (for Internet Explorer prior to Windows 8.0)."
        $npapi = New-Object System.Management.Automation.Host.ChoiceDescription "&NPAPI", "NPAPI:   tries to download and install NPAPI (for Firefox, any Windows)."
        $ppapi = New-Object System.Management.Automation.Host.ChoiceDescription "&PPAPI", "PPAPI:   tries to download and install PPAPI (for Opera and Chromium-based browsers, any Windows)."

        $options_2 = [System.Management.Automation.Host.ChoiceDescription[]]($activex, $npapi, $ppapi, $exit, $abort, $cancel)
        $result_2 = $host.ui.PromptForChoice($title_2, $message_2, $options_2, 5) 

            switch ($result_2)
                {
                    0 {
                    "ActiveX selected.";
                    $empty_line | Out-String
                        If ([System.Environment]::OSVersion.Version -ge '6.2') {
                            $downloading_activex_is_required = $false
                            Write-Warning "Please use Windows Update to update Adobe Flash Player(s) for Internet Explorer (ActiveX) and/or for Edge (ActiveX)."
                            $empty_line | Out-String
                            Write-Output "The Flash Player ActiveX control on Windows 8.1 and above is a component of Internet Explorer and Edge and is updated via Windows Update. By using the standalone Flash Player ActiveX installer, Flash Player ActiveX control cannot be installed on Windows 8.1 and above systems. Also, the Flash Player uninstaller doesn't uninstall the ActiveX control on Windows 8.1 and above systems. For updating the ActiveX Flash Player on Windows 8.1 and above systems, please use the Windows Update."
                            $empty_line | Out-String 
                            Exit
                        } Else {
                            $activex_is_installed = $true
                            $activex_baseline = "[Nonexistent]"
                            $downloading_activex_is_required = $true
                            $continue = $true
                        } # else
                    }
                    1 {
                    "NPAPI selected.";
                    $plugin_is_installed = $true
                    $plugin_baseline = "[Nonexistent]"
                    $downloading_plugin_is_required = $true
                    $continue = $true
                    }
                    2 {
                    "PPAPI selected.";
                    $pepper_is_installed = $true
                    $pepper_baseline = "[Nonexistent]"
                    $downloading_pepper_is_required = $true
                    $continue = $true
                    }                    
                    3 {
                    "Exit. Exiting from Update-AdobeFlashPlayer script.";
                    Exit
                    }
                    4 {
                    "Abort. Exiting from Update-AdobeFlashPlayer script.";
                    Exit
                    }
                    5 {
                    "Cancel. Exiting from Update-AdobeFlashPlayer script.";
                    Exit
                    } # 5                             
                } # switch

    } Else {
        Exit
    } # else (Admin Corner)
} # else (No Flash)




# Check if the PowerShell session is elevated (has been run as an administrator)              # Credit: alejandro5042: "How to run exe with/without elevated privileges from PowerShell"
# Note: This query (and possible exit) could be moved bit further down the script (Step 4 seems to be the first instance, which requires the elevated rights).
If (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator") -eq $false) {
    $empty_line | Out-String
    Write-Warning "It seems that this script is run in a 'normal' PowerShell window."
    $empty_line | Out-String
    Write-Verbose "Please consider running this script in an elevated (administrator-level) PowerShell window." -verbose
    $empty_line | Out-String
    $admin_text = "For performing system altering procedures, such as uninstalling Flash, installing Flash or writing the configuration file of Flash Player (mms.cfg) the elevated rights are mandatory. An elevated PowerShell session can, for example, be initiated by starting PowerShell with the 'run as an administrator' option."
    Write-Output $admin_text
    $empty_line | Out-String   
    # Write-Verbose "Even though it could also be possible to write a self elevating PowerShell script (https://blogs.msdn.microsoft.com/virtual_pc_guy/2010/09/23/a-self-elevating-powershell-script/) or run commands elevated in PowerShell (http://powershell.com/cs/blogs/tips/archive/2014/03/19/running-commands-elevated-in-powershell.aspx) with the UAC prompts, the new UAC pop-up window may come as a surprise to the end-user, who isn't neccesarily aware that this script needs the elevated rights to complete the intended actions."
    Return "Exiting without updating."
} Else {
    $continue = $true
} # else




# Initiate the update process
$empty_line | Out-String
$timestamp = Get-Date -Format hh:mm:ss
$update_text = "$timestamp - Initiating the Flash Update Protocol..."
Write-Output $update_text

# Determine the current directory                                                             # Credit: JaredPar and Matthew Pirocchi "What's the best way to determine the location of the current PowerShell script?"
$script_path = Split-Path -parent $MyInvocation.MyCommand.Definition

# "Manual" progress bar variables
$activity             = "Updating Flash Player"
$status               = "Status"
$id                   = 1 # For using more than one progress bar
$total_steps          = 19 # Total number of the steps or tasks, which will increment the progress bar
$task_number          = 0.2 # An increasing numerical value, which is set at the beginning of each of the steps that increments the progress bar (and the value should be less or equal to total_steps). In essence, this is the "progress" of the progress bar.
$task                 = "Setting Initial Variables" # A description of the current operation, which is set at the beginning of each of the steps that increments the progress bar.

# Start the progress bar
Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

<#
  __
 /_ |
  | |
  | |
  | |
  |_|
    (Step 1) Download the latest full Windows installation file(s) for the Adobe Flash Player
        # Note: The .msi installation files are more handy than the .exe installation files, because msi-files can be deployed over a Windows network using msiexec.exe (supporting an unattended install/uninstall) or installed interactively with software such as Microsoft Systems Management Server (SMS).
        # Source 1: "Installation problems | Flash Player | Windows 7 and earlier": https://helpx.adobe.com/flash-player/kb/installation-problems-flash-player-windows.html
        # Source 2: "Adobe Flash Player Distribution" (This page and the download links will be decommissioned on Sep 29, 2016.): https://www.adobe.com/products/flashplayer/distribution3.html
        # Source 3: "Where to download Flash Player for offline installation?": http://superuser.com/questions/436870/where-to-download-flash-player-for-offline-installation
        # Download URL 1: https://fpdownload.macromedia.com/pub/flashplayer/latest/help/install_flash_player_ax.exe
        # Download URL 2: https://fpdownload.macromedia.com/pub/flashplayer/latest/help/install_flash_player.exe
        # Download URL 3: https://fpdownload.macromedia.com/pub/flashplayer/latest/help/install_flash_player_ppapi.exe
        # Download URL 4: https://fpdownload.macromedia.com/get/flashplayer/current/licensing/win/install_flash_player_23_plugin.msi
        # Download URL 5: https://fpdownload.macromedia.com/get/flashplayer/current/licensing/win/install_flash_player_23_plugin.exe
        # Download URL 6: https://fpdownload.macromedia.com/get/flashplayer/current/licensing/win/install_flash_player_23_active_x.msi
        # Download URL 7: https://fpdownload.macromedia.com/get/flashplayer/current/licensing/win/install_flash_player_23_active_x.exe
        # Download URL 8: https://fpdownload.macromedia.com/get/flashplayer/current/licensing/win/install_flash_player_23_ppapi.msi
        # Download URL 9: https://fpdownload.macromedia.com/get/flashplayer/current/licensing/win/install_flash_player_23_ppapi.exe
        # Download URL 10: http://www.adobe.com/go/full_flashplayer_win_pl_msi
        # Download URL 11: https://get.adobe.com/flashplayer/download/?installer=FP_23_for_Firefox_-_NPAPI&os=Windows%207&browser_type=Gecko&browser_dist=Firefox&dualoffer=false&mdualoffer=true&d=McAfee_Security_Scan_Plus&d=Intel_True_Key&standalone=1
#>

Write-Verbose "Downloading the latest full Windows installation file(s) for the Adobe Flash Player from Adobe..."
Write-Verbose "Depending on how many full installation files are loaded (and on the download speed), this script might take approximately 1.5 - 3 minutes to complete."
$empty_line | Out-String

$activex_url = "https://fpdownload.macromedia.com/pub/flashplayer/latest/help/install_flash_player_ax.exe"
$plugin_url = "https://fpdownload.macromedia.com/pub/flashplayer/latest/help/install_flash_player.exe"
$pepper_url = "https://fpdownload.macromedia.com/pub/flashplayer/latest/help/install_flash_player_ppapi.exe"

$activex_save_location = "$path\install_flash_player_ax.exe"
$plugin_save_location = "$path\install_flash_player.exe"
$pepper_save_location = "$path\install_flash_player_ppapi.exe"

$activex_is_downloaded = $false
$plugin_is_downloaded = $false
$pepper_is_downloaded = $false


If (($activex_is_installed -eq $true) -and ($downloading_activex_is_required -eq $true)) {

    $task_number = 1
    $task = "Downloading the latest full Windows installation file for the ActiveX Adobe Flash Player..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

    # Purge existing old ActiveX installation files
    If ((Test-Path $activex_save_location) -eq $true) {
        Write-Verbose "Deleting $activex_save_location"
        Remove-Item -Path "$activex_save_location"
    } Else {
        $continue = $true
    } # else

    try
    {
        $download_activex = New-Object System.Net.WebClient
        $download_activex.DownloadFile($activex_url, $activex_save_location)
    }
    catch [System.Net.WebException]
    {
        Write-Warning "Failed to access $activex_url"
        $empty_line | Out-String
        Return "Exiting in Step 1 (ActiveX) without updating Flash."
    }

    Start-Sleep -s 2

    If ((Test-Path $activex_save_location) -eq $true) {
        $activex_is_downloaded = $true
    } Else {
        $activex_is_downloaded = $false
    } # else

} Else {
    $continue = $true
} # else




If (($plugin_is_installed -eq $true) -and ($downloading_plugin_is_required -eq $true)) {

    $task_number = 2
    $task = "Downloading the latest full Windows installation file for the NPAPI Adobe Flash Player..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

    # Purge existing old NPAPI installation files
    If ((Test-Path $plugin_save_location) -eq $true) {
        Write-Verbose "Deleting $plugin_save_location"
        Remove-Item -Path "$plugin_save_location"
    } Else {
        $continue = $true
    } # else

    try
    {
        $download_plugin = New-Object System.Net.WebClient
        $download_plugin.DownloadFile($plugin_url, $plugin_save_location)
    }
    catch [System.Net.WebException]
    {
        Write-Warning "Failed to access $plugin_url"
        $empty_line | Out-String
        Return "Exiting in Step 1 (NPAPI) without updating Flash."
    }

    Start-Sleep -s 2

    If ((Test-Path $plugin_save_location) -eq $true) {
        $plugin_is_downloaded = $true
    } Else {
        $plugin_is_downloaded = $false
    } # else

} Else {
    $continue = $true
} # else




If (($pepper_is_installed -eq $true) -and ($downloading_pepper_is_required -eq $true)) {

    $task_number = 3
    $task = "Downloading the latest full Windows installation file for the PPAPI Adobe Flash Player..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

    # Purge existing old PPAPI installation files
    If ((Test-Path $pepper_save_location) -eq $true) {
        Write-Verbose "Deleting $pepper_save_location"
        Remove-Item -Path "$pepper_save_location"
    } Else {
        $continue = $true
    } # else

    try
    {
        $download_pepper = New-Object System.Net.WebClient
        $download_pepper.DownloadFile($pepper_url, $pepper_save_location)
    }
    catch [System.Net.WebException]
    {
        Write-Warning "Failed to access $pepper_url"
        $empty_line | Out-String
        Return "Exiting in Step 1 (PPAPI) without updating Flash."
    }

    Start-Sleep -s 2

    If ((Test-Path $pepper_save_location) -eq $true) {
        $pepper_is_downloaded = $true
    } Else {
        $pepper_is_downloaded = $false
    } # else

} Else {
    $continue = $true
} # else




<#
  ___
 |__ \
    ) |
   / /
  / /_
 |____|
    (Step 2) Download the Flash Player Uninstaller
        # Note: The EXE installer is also able to uninstall Flash at least partially, so this step could be omitted.
        # Note: If .msi install files had been used with msiexec.exe the uninstaller isn't needed at all.
        # Note: FlashUtil.exe (or something similar) in the C:\Windows\System32\Macromed\Flash directory ( %WINDIR%\System32\Macromed\Flash ) is also able to uninstall Flash. When using the FlashUtil<nnn>.exe to uninstall, the user is still required to use the -force argument to perform a complete uninstall.
        # Description 1: "Uninstall Flash Player | Windows": https://helpx.adobe.com/flash-player/kb/uninstall-flash-player-windows.html#main_Download_the_Adobe_Flash_Player_uninstaller
        # Description 2: "Adobe Flash Player Administration Guide": http://www.adobe.com/devnet/flashplayer/articles/flash_player_admin_guide.html
        # Description 3: "Debugger version and installation troubleshooting for developers in Flash Player": https://helpx.adobe.com/flash/kb/debugger-version-installation-troubleshooting.html
        # Description 4: "Silent install command line argument doesn't work | Flash Player 10.1": https://helpx.adobe.com/flash-player/kb/silent-install-command-line-argument.html
        # Download URL: https://fpdownload.macromedia.com/get/flashplayer/current/support/uninstall_flash_player.exe
#>

$uninstaller_url = 'https://fpdownload.macromedia.com/get/flashplayer/current/support/uninstall_flash_player.exe'
$uninstaller_save_location = "$path\uninstall_flash_player.exe"
$uninstaller_is_downloaded = $false

$task_number = 4
$task = "Downloading the Adobe Flash Player uninstaller from Adobe..."
Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

# Purge existing old uninstaller files
If ((Test-Path $uninstaller_save_location) -eq $true) {
    Write-Verbose "Deleting $uninstaller_save_location"
    Remove-Item -Path "$uninstaller_save_location"
} Else {
    $continue = $true
} # else

try
{
    $download_uninstaller = New-Object System.Net.WebClient
    $download_uninstaller.DownloadFile($uninstaller_url, $uninstaller_save_location)
}
catch [System.Net.WebException]
{
    Write-Warning "Failed to access $uninstaller_url"
    $empty_line | Out-String
    Return "Exiting in Step 2 without updating Flash."
}

Start-Sleep -s 2

If ((Test-Path $uninstaller_save_location) -eq $true) {
    $uninstaller_is_downloaded = $true
} Else {
    $uninstaller_is_downloaded = $false
} # else




<#
  ____
 |___ \
   __) |
  |__ <
  ___) |
 |____/
    (Step 3) Exit all browsers and other programs that use Flash, including AOL Instant Messenger, Yahoo Messenger, MSN Messenger, or other Messengers
#>

$task_number = 5
$task = "Stopping Flash-related processes..."
Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

Stop-Process -ProcessName '*messenger*' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'FlashPlayer*' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'plugin-container*' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'chrome*' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'opera*' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'firefox' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'iexplore' -ErrorAction SilentlyContinue -Force
Start-Sleep -s 5

<#
        If (Get-Process iexplore -ErrorAction SilentlyContinue) {
            $empty_line | Out-String
            Write-Warning "It seems that Internet Explorer is running."
            $empty_line | Out-String
            Return "Please close the Internet Explorer and run this script again. Exiting without updating..."
        } Else {
            $continue = $true
        } # else
#>




<#
  _  _
 | || |
 | || |_
 |__   _|
    | |
    |_|
    (Step 4A) Uninstall Adobe Flash Player completely with uninstall_flash_player.exe
        # Note: It seems that Windows PowerShell has to be run in an elevated state (Run as an Administrator) for this script to actually be able to uninstall Flash.
        # Note: The standalone uninstaller from Adobe is definetly not the only way, how Flash Players can be uninstalled. Please see below for futher discussion and examples, how to uninstall Flash.
        # Description 1: "Adobe Flash Player Administration Guide": http://www.adobe.com/devnet/flashplayer/articles/flash_player_admin_guide.html
        # Description 2: "Silent install command line argument doesn't work | Flash Player 10.1": https://helpx.adobe.com/flash-player/kb/silent-install-command-line-argument.html
        # Description 3: https://helpx.adobe.com/flash-player/kb/uninstall-flash-player-windows.html
        # Download URL: See Step #2
#>


If (($activex_is_installed -eq $true) -and ($downloading_activex_is_required -eq $true)) {

    $task_number = 6
    $task = "Uninstalling the ActiveX Adobe Flash Player..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

    cd $path
    .\uninstall_flash_player.exe -uninstall activex | Out-Null
    cd $script_path
    Start-Sleep -s 5

} Else {
    $continue = $true
} # else




If (($plugin_is_installed -eq $true) -and ($downloading_plugin_is_required -eq $true)) {

    $task_number = 7
    $task = "Uninstalling the NPAPI Adobe Flash Player..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

    cd $path
    .\uninstall_flash_player.exe -uninstall plugin | Out-Null
    cd $script_path
    Start-Sleep -s 5

} Else {
    $continue = $true
} # else




If (($pepper_is_installed -eq $true) -and ($downloading_pepper_is_required -eq $true)) {

    $task_number = 8
    $task = "Uninstalling the PPAPI Adobe Flash Player..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)    

    cd $path
    .\uninstall_flash_player.exe -uninstall pepperplugin | Out-Null
    cd $script_path
    Start-Sleep -s 5

} Else {
    $continue = $true
} # else




<#
        # Some uninstall_flash_player.exe commands:
            start /wait $path\uninstall_flash_player.exe -uninstall -force
            Start-Process $path\uninstall_flash_player.exe -uninstall -wait -force
            To uninstall only one particular Flash Player type include the player type (active-x, plugin, or pepperplugin) as an
            argument when uninstalling silently, as follows:
                • ActiveX Control:
                uninstall_flash_player.exe -uninstall activex
                • NPAPI Plugin:
                uninstall_flash_player.exe -uninstall plugin
                • PPAPI Plugin:
                uninstall_flash_player.exe -uninstall pepperplugin
        # Alternative ways to uninstall Adobe Flash Player
            # (4B) Uninstall Adobe Flash Player with the EXE installer
            # Download URL: See Step #1
            cd $path
            .\install_flash_player.exe -uninstall | Out-Null
            # (4C) Uninstall Adobe Flash Player Plugin for Firefox with FlashUtil.exe
                C:\Windows\System32\Macromed\Flash\FlashUtil.exe -uninstall {activex | plugin} -force
            # (4D) Uninstall Adobe Flash Player Plugin for Firefox with MSIExec.exe
                MSIExec.exe /uninstall <package.msi> /quiet (or /passive or /qn)
                        or
                %Comspec% /c msiexec /x "\\network path\install_flash_player_9_activeX.msi" /qn
            # (4E) Uninstall Adobe Flash Player Plugin for Firefox with WMI Win32_Product Class
                $uninstallPlugin = Get-WmiObject -Class Win32_Product -Filter "Name = 'Adobe Flash Player'"
                Trap {Continue}
                $uninstallPlugin.Uninstall() | Out-Null
            # (4F) Uninstall Adobe Flash Player Plugin for Firefox with WMI Win32_Product Class in many computers
                $list = 'host1','host2','host3'                 # your hosts go here
                $application_name = 'appname'                   # your application name goes here (as displayed by win32_product instance)
                $list | ForEach {
                    $host_name = $_
                    Get-WmiObject -Class Win32_Product -Filter "Name = '$application_name'" -ComputerName $_ | ForEach {
                        If ($_.uninstall().returnvalue -eq 0) { write-host "Successfully uninstalled $application_name from $($host_name)" }
                        Else { write-warning "Failed to uninstall $application_name from $($host_name)." }
                    } # foreach (gwmi)
                } # foreach (list)
        # Verify that the Flash Player has been uninstalled: http://www.adobe.com/products/flash/about/
        # Note: Internet Explorer users may have to reboot to clear all uninstalled Flash Player ActiveX control files
#>




<#
  _____
 | ____|
 | |__
 |___ \
  ___) |
 |____/
    (Step 5A) Install the downloaded Flash Player version(s)
        # Note: It seems that Windows PowerShell has to be run in an elevated state (Run as an Administrator) for this script to actually be able to install Flash.
        # Description 1: "Adobe Flash Player Administration Guide": http://www.adobe.com/devnet/flashplayer/articles/flash_player_admin_guide.html
        # Description 2: "Silent install command line argument doesn't work | Flash Player 10.1": https://helpx.adobe.com/flash-player/kb/silent-install-command-line-argument.html
        # Description 3: https://helpx.adobe.com/flash-player/kb/uninstall-flash-player-windows.html
        # Download URL: See Step #1
#>

If ($activex_is_downloaded -eq $true) {

    $task_number = 9
    $task = "Installing the ActiveX Adobe Flash Player..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

    cd $path
    .\install_flash_player_ax.exe -install | Out-Null
    cd $script_path
    Start-Sleep -s 7
} Else {
    $continue = $true
} # else

If ($plugin_is_downloaded -eq $true) {

    $task_number = 10
    $task = "Installing the NPAPI Adobe Flash Player..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

    cd $path
    .\install_flash_player.exe -install | Out-Null
    cd $script_path
    Start-Sleep -s 7
} Else {
    $continue = $true
} # else

If ($pepper_is_downloaded -eq $true) {

    $task_number = 11
    $task = "Installing the PPAPI Adobe Flash Player..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

    cd $path
    .\install_flash_player_ppapi.exe -install | Out-Null
    cd $script_path
    Start-Sleep -s 7
} Else {
    $continue = $true
} # else




<#
        # Alternative ways to install Adobe Flash Player
            # (5B) Install the Flash Player Plugin for Firefox (NPAPI Plugin) as a msi-file with gwmi
                $install_plugin = Get-WmiObject -List 'Win32_Product'
                $install_plugin.Install("$path\install_flash_install_flash_player_22_plugin.msi") | Out-Null
            # (5C) Install the Flash Player Plugin for Firefox (NPAPI Plugin) as a msi-file with msiexec.exe
                msiexec.exe /i <path to MSI>install_flash_player_11_plugin.msi /QB!
                        or
                %Comspec% /c msiexec /i "\\network path\install_flash_player_9_activeX.msi" /qn
#>




<#
    __
   / /
  / /_
 | '_ \
 | (_) |
  \___/
    (Step 6) Configure Adobe Flash Player by creating a backup of the exisiting configuration files and writing new settings to the configuration files
        # Note: Windows PowerShell has to be run in an elevated state (Run as an Administrator) for this script to actually be able to write the mms.cfg files.
        # Description: "Adobe Flash Player Administration Guide": http://www.adobe.com/devnet/flashplayer/articles/flash_player_admin_guide.html
        # Source: http://www.klaus-hartnegg.de/gpo/msi_flash.html
        # Source: http://www.welivesecurity.com/2010/10/06/adobe-flash-the-spy-in-your-computer-part-2/
            mms.cfg file location
                Assuming a default Windows installation, Flash Player looks for the mms.cfg file in the following system directories:
                    • 32-bit Windows - %WINDIR%\System32\Macromed\Flash
                    • 64-bit Windows - %WINDIR%\SysWow64\Macromed\Flash
                    • 32-bit Windows: C:\Windows\System32\Macromed\Flash
                    • 64-bit Windows: C:\Windows\SysWOW64\Macromed\Flash
                
                    The %WINDIR% location above represents the Windows system directory, such as C:\Windows
                
                Google Chrome uses its own version of the mms.cfg file, saved at:
                   • Windows: %USERNAME%/AppData/Local/Google/Chrome/User Data/Default/Pepper Data/Shockwave Flash/System
                This System directory may not exist. If not, create it manually, but caveat emptor, directives such as those relating to updating Flash Player are not honored by Google in Chrome browser as Google embeds Flash Player in Chrome and all updates are released by Google.
            MSI and PKG installers do not provide update options and therefore do not set the update options in the mms.cfg file. To set the update option when installing Flash Player using the MSI or PKG installer deploy a custom mms.cfg file with the desired Update options.
            Starting with version 11.3, the installer contains both the 32 and the 64 bit version, and when running in 64-Bit Windows it will install both versions, which will both use the mms.cfg file from the directory SysWow64.
#>

If ($bit_number -eq "32") {

    $task_number = 12
    $task = "Configuring Adobe Flash Player by writing new settings to the mms.cfg file..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)  

    If ((Test-Path $env:windir\System32\Macromed\Flash\mms_original.cfg) -eq $true) {
        # If the "original" version of the 32-bit backup file exists, do not overwrite it, but instead create another backup that gets overwritten each time this script is run this deep (practically if an update is attempted after the first update attempt, see below)
        copy $env:windir\System32\Macromed\Flash\mms.cfg $env:windir\System32\Macromed\Flash\mms_backup.cfg
    } Else {
        # If an "original" version of this file does not exist, create it (practically when an update is attempted with this script for the first time)
        If ($admin_corner -eq $true) {
            $continue = $true           
        } Else {
            copy $env:windir\System32\Macromed\Flash\mms.cfg $env:windir\System32\Macromed\Flash\mms_original.cfg        
        } # else
    } # else

    $configuration_file_32_bit = New-Item -ItemType File -Path "$env:windir\System32\Macromed\Flash\mms.cfg" -Force
 #   Add-Content $configuration_file_32_bit -Value 'AssetCacheSize = 0'
    Add-Content $configuration_file_32_bit -Value 'AutoUpdateDisable = 1'
    Add-Content $configuration_file_32_bit -Value 'LegacyDomainMatching = 0'
    Add-Content $configuration_file_32_bit -Value 'LocalFileLegacyAction = 0'
 #   Add-Content $configuration_file_32_bit -Value 'LocalStorageLimit = 1'
    Add-Content $configuration_file_32_bit -Value 'SilentAutoUpdateEnable = 0'
 #   Add-Content $configuration_file_32_bit -Value 'ThirdPartyStorage = 0'

} Else {
    $continue = $true
} # else


If ($bit_number -eq "64") {

    $task_number = 12
    $task = "Configuring Adobe Flash Player by writing new settings to the mms.cfg file..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)    

    If ((Test-Path $env:windir\SysWOW64\Macromed\Flash\mms_original.cfg) -eq $true) {
        # If the "original" version of the 32-bit backup file exists, do not overwrite it, but instead create another backup that gets overwritten each time this script is run this deep (practically if an update is attempted after the first update attempt, see below)
        copy $env:windir\SysWOW64\Macromed\Flash\mms.cfg $env:windir\SysWOW64\Macromed\Flash\mms_backup.cfg
    } Else {
        # If an "original" version of this file does not exist, create it (practically when an update is attempted with this script for the first time)
        If ($admin_corner -eq $true) {
            $continue = $true           
        } Else {
            copy $env:windir\SysWOW64\Macromed\Flash\mms.cfg $env:windir\SysWOW64\Macromed\Flash\mms_original.cfg             
        } # else

    } # else

    $configuration_file_64_bit = New-Item -ItemType File -Path "$env:windir\SysWOW64\Macromed\Flash\mms.cfg" -Force
 #   Add-Content $configuration_file_64_bit -Value 'AssetCacheSize = 0'
    Add-Content $configuration_file_64_bit -Value 'AutoUpdateDisable = 1'
    Add-Content $configuration_file_64_bit -Value 'LegacyDomainMatching = 0'
    Add-Content $configuration_file_64_bit -Value 'LocalFileLegacyAction = 0'
 #   Add-Content $configuration_file_64_bit -Value 'LocalStorageLimit = 1'
    Add-Content $configuration_file_64_bit -Value 'SilentAutoUpdateEnable = 0'
 #   Add-Content $configuration_file_64_bit -Value 'ThirdPartyStorage = 0'

} Else {
    $continue = $true
} # else




<#
  ______
 |____  |
     / /
    / /
   / /
  /_/
    (Step 7)  Display the new Flash file version(s) and the success rate of the update process.
#>

# Try to find out which Flash versions, if any, are installed on the system after the update
# Source: "Adobe Flash Player Administration Guide": http://www.adobe.com/devnet/flashplayer/articles/flash_player_admin_guide.html

    $task_number = 13
    $task = "Determining the success rate of the update process..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

<#
            ### .msi installed ActiveX for IE
            ### Note: Get-WmiObject -Class Win32_Product is very slow to run...
            $activex_already_installed = $false
            $activex_major_version = ([version]$xml_activex_win_current).Major
            If (Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq "Adobe Flash Player $activex_major_version ActiveX" -and $_.Version -eq $xml_activex_win_current }) {
                $activex_already_installed = $true
                $activex_already_text = "The most recent version of Adobe Flash Player ActiveX for IE $activex_version is already installed."
                Write-Output $activex_already_text
            } Else {
                $continue = $true
            } # else
#>

# .exe or .msi installed ActiveX for IE
# The player is an OCX file whose name reflects the version number.
$activex_is_installed = $false
If ((Test-Path $env:windir\System32\Macromed\Flash\Flash32*.ocx) -eq $true) {
    # For example, Flash32_11_2_202_228.ocx (32-bit Windows)
    $activex_is_installed = $true
    $new_activex_32_bit_file = Get-ChildItem $env:windir\System32\Macromed\Flash\Flash32*.ocx -ErrorAction Stop
    $new_activex_32_bit_version = ((Get-Item $new_activex_32_bit_file | Select-Object -ExpandProperty VersionInfo).ProductVersion).replace(",",".")
    } If ((Test-Path $env:windir\System32\Macromed\Flash\Flash64*.ocx) -eq $true) {
        # For example, Flash64_11_2_202_228.ocx (64-bit Windows)
        $activex_is_installed = $true
        $new_activex_64_bit_file = Get-ChildItem $env:windir\System32\Macromed\Flash\Flash64*.ocx -ErrorAction Stop
        $new_activex_64_bit_version = ((Get-Item $new_activex_64_bit_file | Select-Object -ExpandProperty VersionInfo).ProductVersion).replace(",",".")
        } If ((Test-Path $env:windir\SysWow64\Macromed\Flash\Flash*.ocx) -eq $true) {
            # For example, Flash32_11_2_202_228.ocx (32-bit Windows)
            $activex_is_installed = $true
            $new_activex_64_bit_in_32_bit_mode_file = Get-ChildItem $env:windir\SysWow64\Macromed\Flash\Flash*.ocx -ErrorAction Stop
            $new_activex_64_bit_in_32_bit_mode_version = ((Get-Item $new_activex_64_bit_in_32_bit_mode_file | Select-Object -ExpandProperty VersionInfo).ProductVersion).replace(",",".")
} Else {
    $continue = $true
} # else




# .msi installed Firefox Plugin (NPAPI)

# .exe or .msi installed Firefox Plugin (NPAPI)
# On Windows, files named NPSWF32.dll (NPSWF64.dll for 64-bit Windows) and flashplayer.xpt are installed, and for Flash Player 11.2 and later, the dll file name also includes the build number.
$plugin_is_installed = $false
If ((Test-Path $env:windir\System32\Macromed\Flash\NPSWF32*.dll) -eq $true) {
    # For example, NPSWF32_11_2_202_228.dll (32-bit Windows)
    $plugin_is_installed = $true
    $new_plugin_32_bit_file = Get-ChildItem $env:windir\System32\Macromed\Flash\NPSWF32*.dll -ErrorAction Stop
    $new_plugin_32_bit_version = ((Get-Item $new_plugin_32_bit_file | Select-Object -ExpandProperty VersionInfo).ProductVersion).replace(",",".")
    } If ((Test-Path $env:windir\System32\Macromed\Flash\NPSWF64*.dll) -eq $true) {
        # For example, NPSWF64_11_2_202_228.dll (64-bit Windows)
        $plugin_is_installed = $true
        $new_plugin_64_bit_file = Get-ChildItem $env:windir\System32\Macromed\Flash\NPSWF64*.dll -ErrorAction Stop
        $new_plugin_64_bit_version = ((Get-Item $new_plugin_64_bit_file | Select-Object -ExpandProperty VersionInfo).ProductVersion).replace(",",".")
        } If ((Test-Path $env:windir\SysWow64\Macromed\Flash\NPSWF*.dll) -eq $true) {
            # For example, NPSWF32_11_2_202_228.dll (32-bit Windows)
            $plugin_is_installed = $true
            $new_plugin_64_bit_in_32_bit_mode_file = Get-ChildItem $env:windir\SysWow64\Macromed\Flash\NPSWF*.dll -ErrorAction Stop
            $new_plugin_64_bit_in_32_bit_mode_version = ((Get-Item $new_plugin_64_bit_in_32_bit_mode_file | Select-Object -ExpandProperty VersionInfo).ProductVersion).replace(",",".")
} Else {
    $continue = $true
} # else




# .msi installed pepper Opera and Chromium-based browsers (PPAPI)

# .exe or .msi installed pepper Opera and Chromium-based browsers (PPAPI)
# On Windows, files named pepflashplayer32.dll (pepflashplayer64.dll for 64-bit Windows) and manifest.json are installed. The dll file name also includes the build number.
$pepper_is_installed = $false
If ((Test-Path $env:windir\System32\Macromed\Flash\pepflashplayer32*.dll) -eq $true) {
    # For example, pepflashplayer32_22_0_0_157.dll (32-bit Windows)
    $pepper_is_installed = $true
    $new_pepper_32_bit_file = Get-ChildItem $env:windir\System32\Macromed\Flash\pepflashplayer32*.dll -ErrorAction Stop
    $new_pepper_32_bit_version = ((Get-Item $new_pepper_32_bit_file | Select-Object -ExpandProperty VersionInfo).ProductVersion).replace(",",".")
    } If ((Test-Path $env:windir\System32\Macromed\Flash\pepflashplayer64*.dll) -eq $true) {
        # For example, pepflashplayer64_22_0_0_157.dll (64-bit Windows)
        $pepper_is_installed = $true
        $new_pepper_64_bit_file = Get-ChildItem $env:windir\System32\Macromed\Flash\pepflashplayer64*.dll -ErrorAction Stop
        $new_pepper_64_bit_version = ((Get-Item $new_pepper_64_bit_file | Select-Object -ExpandProperty VersionInfo).ProductVersion).replace(",",".")
        } If ((Test-Path $env:windir\SysWow64\Macromed\Flash\pepflashplayer*.dll) -eq $true) {
            # For example, pepflashplayer32_22_0_0_157.dll (32-bit Windows)
            $pepper_is_installed = $true
            $new_pepper_64_bit_in_32_bit_mode_file = Get-ChildItem $env:windir\SysWow64\Macromed\Flash\pepflashplayer*.dll -ErrorAction Stop
            $new_pepper_64_bit_in_32_bit_mode_version = ((Get-Item $new_pepper_64_bit_in_32_bit_mode_file | Select-Object -ExpandProperty VersionInfo).ProductVersion).replace(",",".")
} Else {
    $continue = $true
} # else


        $obj_new += New-Object -TypeName PSCustomObject -Property @{
            'Windows Internet Explorer (ActiveX) Flash Player is installed?'                    = $activex_is_installed
            'Windows Firefox (NPAPI) Flash Player is installed?'                                = $plugin_is_installed
            'Windows Opera and Chromium-based browsers (PPAPI) Flash Player is installed?'      = $pepper_is_installed
            'Internet Explorer (ActiveX) Flash Player (32-bit)'                                 = $new_activex_32_bit_version
            'Internet Explorer (ActiveX) Flash Player (64-bit)'                                 = $new_activex_64_bit_version
            'Internet Explorer (ActiveX) Flash Player (64-bit in 32-bit mode)'                  = $new_activex_64_bit_in_32_bit_mode_version
            'Firefox (NPAPI) Flash Player (32-bit)'                                             = $new_plugin_32_bit_version
            'Firefox (NPAPI) Flash Player (64-bit)'                                             = $new_plugin_64_bit_version
            'Firefox (NPAPI) Flash Player (64-bit in 32-bit mode)'                              = $new_plugin_64_bit_in_32_bit_mode_version
            'Opera and Chromium-based browsers (PPAPI) Flash Player (32-bit)'                   = $new_pepper_32_bit_version
            'Opera and Chromium-based browsers (PPAPI) Flash Player (64-bit)'                   = $new_pepper_64_bit_version
            'Opera and Chromium-based browsers (PPAPI) Flash Player (64-bit in 32-bit mode)'    = $new_pepper_64_bit_in_32_bit_mode_version
        } # New-Object
    $obj_new.PSObject.TypeNames.Insert(0,"Flash Player Versions Found on the System After the Update")
    $obj_new_selection = $obj_new | Select-Object 'Windows Internet Explorer (ActiveX) Flash Player is installed?','Windows Firefox (NPAPI) Flash Player is installed?','Windows Opera and Chromium-based browsers (PPAPI) Flash Player is installed?','Internet Explorer (ActiveX) Flash Player (32-bit)','Internet Explorer (ActiveX) Flash Player (64-bit)','Internet Explorer (ActiveX) Flash Player (64-bit in 32-bit mode)','Firefox (NPAPI) Flash Player (32-bit)','Firefox (NPAPI) Flash Player (64-bit)','Firefox (NPAPI) Flash Player (64-bit in 32-bit mode)','Opera and Chromium-based browsers (PPAPI) Flash Player (32-bit)','Opera and Chromium-based browsers (PPAPI) Flash Player (64-bit)','Opera and Chromium-based browsers (PPAPI) Flash Player (64-bit in 32-bit mode)'


    # Display the Flash version numbers, which are found on the system after the update, in console
    $empty_line | Out-String
    $header_new = "Flash Player Versions Found on the System After the Update"
    $coline_new = "----------------------------------------------------------"
    Write-Output $header_new
    $coline_new | Out-String
    Write-Output $obj_new_selection
    $empty_line | Out-String




# Determine the new installed Flash version numbers regardles whether the system is 32- or 64-bits.
If ($new_activex_64_bit_in_32_bit_mode_version -ne $null) { $new_activex_baseline = $new_activex_64_bit_in_32_bit_mode_version } Else { $continue = $true }
If ($new_activex_32_bit_version -ne $null)                { $new_activex_baseline = $new_activex_32_bit_version }                Else { $continue = $true }
If ($new_activex_64_bit_version -ne $null)                { $new_activex_baseline = $new_activex_64_bit_version }                Else { $continue = $true }

If ($new_plugin_64_bit_in_32_bit_mode_version -ne $null)  { $new_plugin_baseline = $new_plugin_64_bit_in_32_bit_mode_version }   Else { $continue = $true }
If ($new_plugin_32_bit_version -ne $null)                 { $new_plugin_baseline = $new_plugin_32_bit_version }                  Else { $continue = $true }
If ($new_plugin_64_bit_version -ne $null)                 { $new_plugin_baseline = $new_plugin_64_bit_version }                  Else { $continue = $true }

If ($new_pepper_64_bit_in_32_bit_mode_version -ne $null)  { $new_pepper_baseline = $new_pepper_64_bit_in_32_bit_mode_version }   Else { $continue = $true }
If ($new_pepper_32_bit_version -ne $null)                 { $new_pepper_baseline = $new_pepper_32_bit_version }                  Else { $continue = $true }
If ($new_pepper_64_bit_version -ne $null)                 { $new_pepper_baseline = $new_pepper_64_bit_version }                  Else { $continue = $true }




# Determine the success rate of the update process.
If ($downloading_activex_is_required -eq $true) {

    $most_recent_activex_after_update = Check-InstalledSoftware "Adobe Flash Player $most_recent_activex_major_version ActiveX" $xml_activex_win_current
    If ($most_recent_activex_after_update) {
        $success_activex = $true
        Write-Output "The $bit_number-bit ActiveX was updated successfully from v$activex_baseline to v$new_activex_baseline. Currently (until the next Flash Player version is released) Adobe Flash Player for Internet Explorer (ActiveX) v$new_activex_baseline doesn't need any further maintenance or care."
        $empty_line | Out-String
    } Else {
        $success_activex = $false
        $empty_line | Out-String
        Write-Warning "Failed to update $bit_number-bit ActiveX"
        $empty_line | Out-String
        Write-Output "Adobe Flash Player for Internet Explorer (ActiveX) v$new_activex_baseline seems to be outdated. The most recent non-beta Flash version of ActiveX is v$xml_activex_win_current. The installed Flash version v$new_activex_baseline needs to be updated. This script tried to update the $bit_number-bit ActiveX, but failed to do so."
        $empty_line | Out-String
    } # else

} Else {
    $continue = $true
} # else




If ($downloading_plugin_is_required -eq $true) {

    $most_recent_plugin_after_update = Check-InstalledSoftware "Adobe Flash Player $most_recent_plugin_major_version NPAPI" $xml_plugin_win_current
    If ($most_recent_plugin_after_update) {
        $success_plugin = $true
        Write-Output "The $bit_number-bit NPAPI was updated successfully from v$plugin_baseline to v$new_plugin_baseline. Currently (until the next Flash Player version is released) Adobe Flash Player for Firefox (NPAPI) v$new_plugin_baseline doesn't need any further maintenance or care."
        $empty_line | Out-String
    } Else {
        $success_plugin = $false
        $empty_line | Out-String
        Write-Warning "Failed to update $bit_number-bit NPAPI"
        $empty_line | Out-String
        Write-Output "Adobe Flash Player for Firefox (NPAPI) v$new_plugin_baseline seems to be outdated. The most recent non-beta Flash version of NPAPI is v$xml_plugin_win_current. The installed Flash version v$new_plugin_baseline needs to be updated. This script tried to update the $bit_number-bit NPAPI, but failed to do so."
        $empty_line | Out-String
    } # else

} Else {
    $continue = $true
} # else




If ($downloading_pepper_is_required -eq $true) {

    $most_recent_pepper_after_update = Check-InstalledSoftware "Adobe Flash Player $most_recent_pepper_major_version PPAPI" $xml_ppapi_win_current
    If ($most_recent_pepper_after_update) {
        $success_pepper = $true
        Write-Output "The $bit_number-bit PPAPI was updated successfully from v$pepper_baseline to v$new_pepper_baseline. Currently (until the next Flash Player version is released) Adobe Flash Player for Opera and Chromium-based browsers (PPAPI) v$new_pepper_baseline doesn't need any further maintenance or care."
        $empty_line | Out-String
    } Else {
        $success_pepper = $false
        $empty_line | Out-String
        Write-Warning "Failed to update $bit_number-bit PPAPI"
        $empty_line | Out-String
        Write-Output "Adobe Flash Player for Opera and Chromium-based browsers (PPAPI) v$new_pepper_baseline seems to be outdated. The most recent non-beta Flash version of PPAPI is v$xml_ppapi_win_current. The installed Flash version v$new_pepper_baseline needs to be updated. This script tried to update the $bit_number-bit PPAPI, but failed to do so."
        $empty_line | Out-String
    } # else

} Else {
    $continue = $true
} # else




# Reiterate the status of the up-to-date Flash versions
If (($activex_is_installed -eq $true) -and ($downloading_activex_is_required -eq $false)) {
    $not_touched_activex = $true
    If ([System.Environment]::OSVersion.Version -lt '6.2') {
            $activex_ok = $true
            Write-Output "As deemed earlier, currently (until the next Flash Player version is released) Adobe Flash Player for Internet Explorer (ActiveX) v$activex_baseline doesn't need any further maintenance or care. This script didn't alter the $bit_number-bit ActiveX."
            $empty_line | Out-String
    } ElseIf ([System.Environment]::OSVersion.Version -ge '6.2') {
        If ($xml_activex_win_current -eq $activex_baseline) {
            $activex_ok = $true
            Write-Output "As deemed earlier, currently (until the next Flash Player version is released) the ActiveX Adobe Flash Player for Internet Explorer and/or for Edge v$activex_baseline doesn't need any further maintenance or care. This script didn't alter the $bit_number-bit ActiveX."
            $empty_line | Out-String
        } Else {
            $activex_ok = $false
            Write-Warning "Please use Windows Update to update Adobe Flash Player(s) for Internet Explorer (ActiveX) and/or for Edge (ActiveX)."
            $empty_line | Out-String
            Write-Output "Adobe Flash Player for Internet Explorer (ActiveX) v$activex_baseline seems to be outdated. The most recent non-beta Flash version of ActiveX is v$xml_activex_win_current. The installed ActiveX Flash version v$activex_baseline needs to be updated. However, the Flash Player ActiveX control on Windows 8.1 and above is a component of Internet Explorer and Edge and is updated via Windows Update. By using the standalone Flash Player ActiveX installer, Flash Player ActiveX control cannot be installed on Windows 8.1 and above systems. Also, the Flash Player uninstaller doesn't uninstall the ActiveX control on Windows 8.1 and above systems. For updating the ActiveX Flash Player on Windows 8.1 and above systems, please use the Windows Update. This script didn't alter the $bit_number-bit ActiveX."
            $empty_line | Out-String
        } # else

    } Else {
        $continue = $true
    } # else

} Else {
    $continue = $true
} # else




If (($plugin_is_installed -eq $true) -and ($downloading_plugin_is_required -eq $false)) {

    $not_touched_plugin = $true
    Write-Output "As deemed earlier, currently (until the next Flash Player version is released) Adobe Flash Player for Firefox (NPAPI) v$plugin_baseline doesn't need any further maintenance or care. This script didn't alter the $bit_number-bit NPAPI."
    $empty_line | Out-String

} Else {
    $continue = $true
} # else




If (($pepper_is_installed -eq $true) -and ($downloading_pepper_is_required -eq $false)) {

    $not_touched_pepper = $true
    Write-Output "As deemed earlier, currently (until the next Flash Player version is released) Adobe Flash Player for Opera and Chromium-based browsers (PPAPI) v$pepper_baseline doesn't need any further maintenance or care. This script didn't alter the $bit_number-bit PPAPI."
    $empty_line | Out-String

} Else {
    $continue = $true
} # else




        $obj_success += New-Object -TypeName PSCustomObject -Property @{
            'Adobe Flash Player for Internet Explorer (ActiveX)'                = If ($downloading_activex_is_required -eq $true) { $success_activex } ElseIf ($activex_ok -eq $true) { "Already up-to-date before the script was started" } ElseIf ($activex_ok -eq $false) { "False: Please use Windows Update to update Flash" } Else { "-" }
            'Adobe Flash Player for Firefox (NPAPI)'                            = If ($downloading_plugin_is_required -eq $true) { $success_plugin } ElseIf ($not_touched_plugin -eq $true) { "Already up-to-date before the script was started" } Else { "-" }
            'Adobe Flash Player for Opera and Chromium-based browsers (PPAPI)'  = If ($downloading_pepper_is_required -eq $true) { $success_pepper } ElseIf ($not_touched_pepper -eq $true) { "Already up-to-date before the script was started" } Else { "-" }
        } # New-Object
    $obj_success.PSObject.TypeNames.Insert(0,"The Updating Procedure Went Successfully for These Flash Versions")
    $obj_success_selection = $obj_success | Select-Object 'Adobe Flash Player for Internet Explorer (ActiveX)','Adobe Flash Player for Firefox (NPAPI)','Adobe Flash Player for Opera and Chromium-based browsers (PPAPI)'


    # Display in console the success rate of the update process
    $empty_line | Out-String
    $empty_line | Out-String
    $header_success = "The Updating Procedure Went Successfully for the Following Flash Versions"
    $coline_success = "-------------------------------------------------------------------------"
    Write-Output $header_success
    $coline_success | Out-String
    $obj_success_selection
    $empty_line | Out-String




# Determine the current status of Flash and find out if the script should stop or not
If (($activex_is_installed -eq $true) -or ($plugin_is_installed -eq $true) -or ($pepper_is_installed -eq $true)) {

    If (($success_activex -ne $false) -and ($success_plugin -ne $false) -and ($success_pepper -ne $false) -and ($activex_ok -ne $false) -and ($activex_exception -eq $true)) {
        Write-Output "Please use Windows Update to update the ActiveX-version of Adobe Flash Player."
        $continue = $true
    } ElseIf (($success_activex -ne $false) -and ($success_plugin -ne $false) -and ($success_pepper -ne $false) -and ($activex_ok -ne $false)) {
        Write-Output "The installed Flash seems to be OK."
        $continue = $true
    } Else {
        If ($activex_ok -eq $false) {
            $continue = $true
        } Else {     
            Return "Encountered a problem when installing the Flash. Exiting in Step 7 without deleting the downloaded files."
        } # else
    } # else
} Else {
    Write-Warning "No Flash (ActiveX, NPAPI or PPAPI) seems to be installed on the system."
    $empty_line | Out-String
    Write-Verbose "Ooops..." -verbose
    $empty_line | Out-String
    $fail_text_1 = "After this script had downloaded the installation file(s) and run its update procedure,"
    $fail_text_2 = "it didn't detect that any of the three types of Flash Players mentioned above"
    $fail_text_3 = "would have been installed. Please consider installing the Flash Player by visiting"
    $fail_text_4 = "https://get.adobe.com/flashplayer/ or https://get.adobe.com/flashplayer/otherversions/" 
    $fail_text_5 = "For full installation files please, for example, see the bottom of the page"
    $fail_text_6 = "https://helpx.adobe.com/flash-player/kb/installation-problems-flash-player-windows.html"
    $fail_text_7 = "and for the Adobe Flash uninstaller, please visit" 
    $fail_text_8 = "https://helpx.adobe.com/flash-player/kb/uninstall-flash-player-windows.html"
    Write-Output $fail_text_1
    Write-Output $fail_text_2
    Write-Output $fail_text_3
    Write-Output $fail_text_4
    Write-Output $fail_text_5
    Write-Output $fail_text_6
    Write-Output $fail_text_7
    Write-Output $fail_text_8
    Write-Output $fail_text_9
    Exit
} # else




<#
   ___
  / _ \
 | (_) |
  > _ <
 | (_) |
  \___/
    (Step 8) Verify that the Flash Player has been installed by opening a web page in the default browser
#>

    $task_number = 14
    $task = "Verifying that the Flash Player has been installed by opening a web page in the default browser..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)


Start-Process -FilePath "http://www.adobe.com/products/flash/about/" | Out-Null

# Start-Process -FilePath "https://helpx.adobe.com/flash-player.html" | Out-Null

### For opening Internet Explorer
# $ie = New-Object -ComObject "InternetExplorer.Application" 
# $ie.visible = $true 
# $ie.navigate("http://www.adobe.com/products/flash/about/") 




<#
   ___
  / _ \
 | (_) |
  \__, |
    / /
   /_/
    (Step 9) Delete the downloaded files and find out how long the script took to complete
#>

Start-Sleep -s 10

If ($uninstaller_is_downloaded -eq $true) {

    $task_number = 15
    $task = "Deleting the downloaded files..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

    Remove-Item -Path "$uninstaller_save_location"
} Else {
    $continue = $true
} # else

If ($activex_is_downloaded -eq $true) {

    $task_number = 16
    $task = "Deleting the downloaded files..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

    Remove-Item -Path "$activex_save_location"
} Else {
    $continue = $true
} # else

If ($plugin_is_downloaded -eq $true) {

    $task_number = 17
    $task = "Deleting the downloaded files..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

    Remove-Item -Path "$plugin_save_location"
} Else {
    $continue = $true
} # else

If ($pepper_is_downloaded -eq $true) {

    $task_number = 18
    $task = "Deleting the downloaded files..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

    Remove-Item -Path "$pepper_save_location"
} Else {
    $continue = $true
} # else


# Close the progress bar
$task_number = 19
$task = "Finished updating Flash."
Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100) -Completed


# Find out how long the script took to complete
$end_time = Get-Date
$runtime = ($end_time) - ($start_time)

    If ($runtime.Days -ge 2) {
        $runtime_result = [string]$runtime.Days + ' days ' + $runtime.Hours + ' h ' + $runtime.Minutes + ' min'
    } ElseIf ($runtime.Days -gt 0) {
        $runtime_result = [string]$runtime.Days + ' day ' + $runtime.Hours + ' h ' + $runtime.Minutes + ' min'
    } ElseIf ($runtime.Hours -gt 0) {
        $runtime_result = [string]$runtime.Hours + ' h ' + $runtime.Minutes + ' min'
    } ElseIf ($runtime.Minutes -gt 0) {
        $runtime_result = [string]$runtime.Minutes + ' min ' + $runtime.Seconds + ' sec'
    } ElseIf ($runtime.Seconds -gt 0) {
        $runtime_result = [string]$runtime.Seconds + ' sec'
    } ElseIf ($runtime.Milliseconds -gt 1) {
        $runtime_result = [string]$runtime.Milliseconds + ' milliseconds'
    } ElseIf ($runtime.Milliseconds -eq 1) {
        $runtime_result = [string]$runtime.Milliseconds + ' millisecond'       
    } ElseIf (($runtime.Milliseconds -gt 0) -and ($runtime.Milliseconds -lt 1)) {
        $runtime_result = [string]$runtime.Milliseconds + ' milliseconds'                
    } Else {
        $runtime_result = [string]''
    } # else (if)

        If ($runtime_result.Contains(" 0 h")) {
            $runtime_result = $runtime_result.Replace(" 0 h"," ")
            } If ($runtime_result.Contains(" 0 min")) {
                $runtime_result = $runtime_result.Replace(" 0 min"," ")
                } If ($runtime_result.Contains(" 0 sec")) {
                $runtime_result = $runtime_result.Replace(" 0 sec"," ")
        } # if ($runtime_result: first)

# Display the runtime in console
$empty_line | Out-String
$timestamp_end = Get-Date -Format hh:mm:ss
$end_text = "$timestamp_end - The Flash Update Protocol completed."
Write-Output $end_text
$empty_line | Out-String
$runtime_text = "The update took $runtime_result."
Write-Output $runtime_text
$empty_line | Out-String




# [End of Line]


<#
   _____
  / ____|
 | (___   ___  _   _ _ __ ___ ___
  \___ \ / _ \| | | | '__/ __/ _ \
  ____) | (_) | |_| | | | (_|  __/
 |_____/ \___/ \__,_|_|  \___\___|
http://powershell.com/cs/forums/t/6128.aspx                                                                         # Bob Ross: "Automated Adobe Flash Player Maintenance PowerScript for Public Computing Environment"
http://powershell.com/cs/blogs/tips/archive/2011/05/04/test-internet-connection.aspx                                # ps1: "Test Internet connection"
http://powershell.com/cs/PowerTips_Monthly_Volume_8.pdf#IDERA-1702_PS-PowerShellMonthlyTipsVol8-jan2014             # Tobias Weltner: "PowerTips Monthly vol 8 January 2014"
http://stackoverflow.com/questions/29266622/how-to-run-exe-with-without-elevated-privileges-from-powershell?rq=1    # alejandro5042: "How to run exe with/without elevated privileges from PowerShell"
https://community.spiceworks.com/topic/487699-a-little-powershell-help-flash-version-query                          # Raven Hunter: "A little powershell help, Flash Version Query"
https://www.reddit.com/r/PowerShell/comments/3tgr2m/get_current_versions_of_adobe_products/                         # Kreloc: "Get current versions of Adobe Products"
https://chocolatey.org/packages/flashplayerplugin                                                                   # chocolatey: "Flash Player Plugin"
http://stackoverflow.com/questions/5466329/whats-the-best-way-to-determine-the-location-of-the-current-powershell-script?noredirect=1&lq=1      # JaredPar and Matthew Pirocchi "What's the best way to determine the location of the current PowerShell script?"
https://technet.microsoft.com/en-us/library/ff730939.aspx                                                           # "Adding a Simple Menu to a Windows PowerShell Script"
http://powershell.com/cs/forums/t/9685.aspx                                                                         # lamaar75: "Creating a Menu"
  _    _      _
 | |  | |    | |
 | |__| | ___| |_ __
 |  __  |/ _ \ | '_ \
 | |  | |  __/ | |_) |
 |_|  |_|\___|_| .__/
               | |
               |_|
#>

<#
.SYNOPSIS
Retrieves the latest Flash Player version numbers, and looks for the installed Flash
versions on the system. If any outdated Flash versions are found, updates the three
Windows Adobe Flash Players (NPAPI and PPAPI in any Windows machine and ActiveX in
pre Windows 8.1 machines (On Windows 8.1 and above, the ActiveX Flash is updated via
Windows Update)).
.DESCRIPTION
Update-AdobeFlashPlayer downloads a list of the most recent Flash version numbers
against which it compares the Flash version numbers found on the system and displays,
whether a Flash update is needed or not. If a working Internet connection is not
found, Update-AdobeFlashPlayer will exit at an early stage without displaying any
info apart from what is found on the system. The actual update process naturally
needs elevated rights, but if, however, all detected Flash Players seem to be
up-to-date, Update-AdobeFlashPlayer will exit before checking, whether it is run
elevated or not. Thus, if Update-AdobeFlashPlayer is run in a up-to-date machine
in a 'normal' PowerShell window, Update-AdobeFlashPlayer will just check that
everything is OK and leave without further ceremony.
If Update-AdobeFlashPlayer is run without elevated rights (but with a working
Internet connection) in a machine with old Flash versions, it will be shown that a
Flash update is needed, but Update-AdobeFlashPlayer will exit with a fail before
actually downloading any files or making any changes to the system. To perform an
update with Update-AdobeFlashPlayer, PowerShell has to be run in an elevated window
(run as an administrator).
If Update-AdobeFlashPlayer is run in an elevated PowerShell window and no Flash is 
detected, the script offers the option to install one specific version of Flash in 
two steps in the "Admin Corner", where, in contrary to the main autonomous nature of 
Update-AdobeFlashPlayer, an end-user input is required.
In the update procedure (if old Flash has been found and Update-AdobeFlashPlayer 
is run with administrative rights) Update-AdobeFlashPlayer downloads the Flash 
uninstaller from Adobe and (a) full Flash installer(s) for the type(s) of Flash 
Player(s) from Adobe, which it has deemed to be outdated and after stopping several 
Flash-related processes uninstalls the outdated Flash version(s) and installs the 
downloaded Flash Player(s). Adobe Flash Player is configured by creating a backup 
of the exisiting configuration file (mms.cfg) and overwriting new settings to the 
configuration file. After the installation a web page in the default browser is 
opened for verifying that the Flash Player has been installed correctly. The 
downloaded files are purged from the hard drive after a while. This script is
based on Bob Ross' PowerShell script "Automated Adobe Flash Player Maintenance 
PowerScript for Public Computing Environment"
(http://powershell.com/cs/forums/t/6128.aspx).
.OUTPUTS
Displays Flash related information in console. Tries to update outdated Adobe Flash 
Player(s) to its/their latest version(s), if old Flash Player(s) is/are found and 
if Update-AdobeFlashPlayer is run in an elevated Powershell window. In addition to 
that, if such an update procedure is initiated...
the Flash Player configuration file (mms.cfg) is overwritten with new parameters
and the following backups are made:
    Configuration file:
        32-bit Windows:   %WINDIR%\System32\Macromed\Flash\mms.cfg
        64-bit Windows:   %WINDIR%\SysWow64\Macromed\Flash\mms.cfg
    'Original' file, which is created when the script tries to update something for 
    the first time:
        32-bit Windows:   %WINDIR%\System32\Macromed\Flash\mms_original.cfg
        64-bit Windows:   %WINDIR%\SysWow64\Macromed\Flash\mms_original.cfg
    'Backup' file, which is created when the script tries to update something for 
    the second time and which gets overwritten in each successive update cycle:
        32-bit Windows:   %WINDIR%\System32\Macromed\Flash\mms_backup.cfg
        64-bit Windows:   %WINDIR%\SysWow64\Macromed\Flash\mms_backup.cfg
    The %WINDIR% location represents the Windows system directory, such as
    C:\Windows and may be displayed in PowerShell with the $env:windir varible.
To see the actual values that are being written, please see Step 6 above (altering 
the duplicated values below won't affect the script in any meaningful way) 
 #  [AssetCacheSize = 0         Disables storing the common Flash components] 
    AutoUpdateDisable = 1       Disables the Automatic Flash Update
    LegacyDomainMatching = 0    Denies Flash Player 6 and earlier superdomain rules
    LocalFileLegacyAction = 0   Denies Flash Player 7 and earlier local-trusted sandbox
 #  [LocalStorageLimit = 1      Disables persistent shared objects]
    SilentAutoUpdateEnable = 0  Disables background updates
 #  [ThirdPartyStorage = 0      Denies third-party locally persistent shared objects]
    Most of the settings above may render some web pages broken.
    Lines marked with # are written only if the symbol # is removed from the 
    beginning of the appropriate line inside the source code section (above the 
    SYNOPSIS header, Step 6, about at line ~1111).  
For a comprehensive list of available settings and a more detailed description 
of the values above, please see the "Adobe Flash Player Administration Guide" at
http://www.adobe.com/devnet/flashplayer/articles/flash_player_admin_guide.html  
To open these file locations in a Resource Manager Window, for instance a command
    Invoke-Item $env:windir\System32\Macromed\Flash\
            or
    Invoke-Item $env:windir\SysWOW64\Macromed\Flash\
may be used at the PowerShell prompt window [PS>].  
.NOTES
Requires a working Internet connection for downloading a list of the most recent 
Flash version numbers. 
Also requires a working Internet connection for downloading a Flash uninstaller 
and a complete Flash installer(s) from Adobe (but this procedure is not initiated, 
if the system is deemed up-to-date).
For performing any actual updates with Update-AdobeFlashPlayer, it's mandatory to 
run this script in an elevated PowerShell window (where PowerShell has been started 
with the 'run as an administrator' option). The elevated rights are needed for 
uninstalling Flash, installing Flash and for writing the mms.cfg file.
Please also notice that during the actual update phase Update-AdobeFlashPlayer 
closes a bunch of processes without any further notice in Step 3 and in Step 6 
Update-AdobeFlashPlayer alters the Flash configuration file (mms.cfg) so, that for 
instance, the automatic Flash updates are turned off.
The Flash Player ActiveX control on Windows 8.1 and above is a component of Internet 
Explorer and Edge and is updated via Windows Update. By using the Flash Player 
ActiveX installer, Flash Player ActiveX control cannot be installed on Windows 8.1 
and above systems. Also, the Flash Player uninstaller doesn't uninstall the ActiveX 
control on Windows 8.1 and above systems.
Please note that when run in an elevated PowerShell window and old Flash Player(s) 
is/are detected, Update-AdobeFlashPlayer will automatically try to download files 
from the Internet without prompting the end-user beforehand or without asking any 
confirmations (in Step 1 and Step 2).
Please note that the downloaded files are temporarily placed in a directory, which 
is specified with the $path variable (at line 75). The $env:temp variable points 
to the current temp folder. The default value of the $env:temp variable is 
C:\Users\<username>\AppData\Local\Temp (i.e. each user account has their own 
separate temp folder at path %USERPROFILE%\AppData\Local\Temp). To see the current 
temp path, for instance a command
    [System.IO.Path]::GetTempPath()
may be used at the PowerShell prompt window [PS>]. To change the temp folder for instance
to C:\Temp, please, for example, follow the instructions at
http://www.eightforums.com/tutorials/23500-temporary-files-folder-change-location-windows.html
    Homepage:           https://github.com/auberginehill/update-adobe-flash-player
    Short URL:          http://tinyurl.com/gve9y8s
    Version:            1.3
.EXAMPLE
./Update-AdobeFlashPlayer
Run the script. Please notice to insert ./ or .\ before the script name.
.EXAMPLE
help ./Update-AdobeFlashPlayer -Full
Display the help file.
.EXAMPLE
Set-ExecutionPolicy remotesigned
This command is altering the Windows PowerShell rights to enable script execution. Windows PowerShell
has to be run with elevated rights (run as an administrator) to actually be able to change the script
execution properties. The default value is "Set-ExecutionPolicy restricted".
    Parameters:
    Restricted      Does not load configuration files or run scripts. Restricted is the default
                    execution policy.
    AllSigned       Requires that all scripts and configuration files be signed by a trusted
                    publisher, including scripts that you write on the local computer.
    RemoteSigned    Requires that all scripts and configuration files downloaded from the Internet
                    be signed by a trusted publisher.
    Unrestricted    Loads all configuration files and runs all scripts. If you run an unsigned
                    script that was downloaded from the Internet, you are prompted for permission
                    before it runs.
    Bypass          Nothing is blocked and there are no warnings or prompts.
    Undefined       Removes the currently assigned execution policy from the current scope.
                    This parameter will not remove an execution policy that is set in a Group
                    Policy scope.
For more information,
type "help Set-ExecutionPolicy -Full" or visit https://technet.microsoft.com/en-us/library/hh849812.aspx.
.EXAMPLE
New-Item -ItemType File -Path C:\Temp\Update-AdobeFlashPlayer.ps1
Creates an empty ps1-file to the C:\Temp directory. The New-Item cmdlet has an inherent -NoClobber mode
built into it, so that the procedure will halt, if overwriting (replacing the contents) of an existing
file is about to happen. Overwriting a file with the New-Item cmdlet requires using the Force.
For more information, please type "help New-Item -Full".
.LINK
http://powershell.com/cs/forums/t/6128.aspx
http://powershell.com/cs/blogs/tips/archive/2011/05/04/test-internet-connection.aspx
http://powershell.com/cs/PowerTips_Monthly_Volume_8.pdf#IDERA-1702_PS-PowerShellMonthlyTipsVol8-jan2014
http://stackoverflow.com/questions/29266622/how-to-run-exe-with-without-elevated-privileges-from-powershell?rq=1
https://community.spiceworks.com/topic/487699-a-little-powershell-help-flash-version-query
https://www.reddit.com/r/PowerShell/comments/3tgr2m/get_current_versions_of_adobe_products/
https://chocolatey.org/packages/flashplayerplugin
http://stackoverflow.com/questions/5466329/whats-the-best-way-to-determine-the-location-of-the-current-powershell-script?noredirect=1&lq=1
http://powershell.com/cs/forums/t/9685.aspx
https://www.credera.com/blog/technology-insights/perfect-progress-bars-for-powershell/
https://technet.microsoft.com/en-us/library/ff730939.aspx
https://msdn.microsoft.com/en-us/library/aa393941(v=vs.85).aspx
#>