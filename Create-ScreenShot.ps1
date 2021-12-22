#############################################################################
# Capturing a screenshot
#############################################################################
$Path = "$env:USERPROFILE"+"\appdata\roaming\microsoft\windows\Screenshot"
$FileName = "$env:COMPUTERNAME-$env:USERNAME-$(get-date -f yyyy-MM-dd_HHmmss).bmp"
$File = "$Path\$FileName"
If (!(test-path $Path))
    {
        New-Item -Path $Path -ItemType Directory -Force | %{$_.Attributes = "hidden"}
    }

Add-Type -AssemblyName System.Windows.Forms
Add-type -AssemblyName System.Drawing

# Gather Screen resolution information
$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
$Width = $Screen.Width
$Height = $Screen.Height
$Left = $Screen.Left
$Top = $Screen.Top

# Create bitmap using the top-left and bottom-right bounds
$bitmap = New-Object System.Drawing.Bitmap $Width, $Height

# Create Graphics object
$graphic = [System.Drawing.Graphics]::FromImage($bitmap)

# Capture screen
$graphic.CopyFromScreen($Left, $Top, 0, 0, $bitmap.Size)

# Save to file
$bitmap.Save($File) 

rename-item -Path $File -NewName "$file.old" -Force

Write-Output "Screenshot saved to:"
Write-Output $File