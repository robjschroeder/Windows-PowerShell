$recoveryKeyPath = "\\server.domain.com\BitLocker\keys\$env:computername"
$recoveryTXTFileName = "RecoveryPassword-$env:computername.txt"
$recoveryTXTFileFullPath = "$recoveryKeyPath\$recoveryTXTFileName"
$TPMRecoveryFile = "$env:computername"
$mountPoint = Read-Host "Please enter the mount point for the bitlocker drive (i.e C:, D:)"
# $Tpm = Get-wmiobject -Namespace ROOT\CIMV2\Security\MicrosoftTpm -Class Win32_Tpm
# $tpm | gm

If (!(Test-Path "\\sever.domain.com\BitLocker"))
    {
        Write-Output "Please map to '\\server.domain.com\BitLocker and run this script again" | Write-Host -ForegroundColor Red
        Exit
    }
ElseIf (Test-Path -Path "$recoveryKeyPath")
    {
        Write-Output "Error - folder `"$recoveryKeyPath`" already exists"
    }
Elseif (Test-Path -Path "$recoveryTXTFileFullPath")
    {
        Write-Output "Error - file `"$recoveryTXTFileFullPath`" already exists"
    }
Else
    {
        Enable-BitLocker -MountPoint "$env:SystemDrive" -EncryptionMethod Aes256 -SkipHardwareTest -RecoveryPasswordProtector

        do 
            {
                $Volume = Get-BitLockerVolume -MountPoint "$mountPoint"
                Write-Progress -Activity "Encrypting volume $($Volume.MountPoint)" -Status "Encryption Progress:" -PercentComplete $Volume.EncryptionPercentage -Completed
                Start-Sleep -Seconds 1
            }
        until ($Volume.VolumeStatus -eq 'FullyEncrypted')

        
        manage-bde -protectors -get $env:systemdrive *>&1> "$recoveryTXTFileFullPath"

        <#
        $Volume = Get-BitLockerVolume -MountPoint "$mountPoint"
        $recoveryKeyProtector = ""
        foreach ($keyProtector in $volume.KeyProtector)
            {
                if ($keyProtector.KeyProtectorType -eq "RecoveryPassword")
                    {
                        $recoveryKeyProtector = $keyProtector
                    }
            }
        #>
                                        
    }