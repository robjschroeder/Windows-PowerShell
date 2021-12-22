# Sets BIOS configuration using Dell BIOS Provider
$pwd = "biosPassword"
Import-Module DellBIOSProvider
Set-Item -Path DellSmbios:\Security\AdminPassword "" -Password $pwd
Set-Item -Path DellSmbios:\BootSequence\BootList "Uefi"
Set-Item -Path DellSmbios:\AdvancedBootOptions\LegacyOrom "Disabled"
Set-Item -Path DellSmbios:\AdvancedBootOptions\AttemptLegacyBoot "Disabled"
Set-Item -Path DellSmbios:\AdvancedBootOptions\UefiBootPathSecurity "AlwaysExceptInternalHdd"
Set-Item -Path DellSmbios:\SystemConfiguration\DustFilter "Disabled"
Set-Item -Path DellSmbios:\SystemConfiguration\WatchdogTimer "Disabled"
Set-Item -Path DellSmbios:\SystemConfiguration\EmbNic1 "EnabledPxe"
Set-Item -Path DellSmbios:\SystemConfiguration\UefiNwStack "Enabled"
Set-Item -Path DellSmbios:\SystemConfiguration\SmartErrors "Enabled"
Set-Item -Path DellSmbios:\Video\PrimaryVideoSlot "Auto"
Set-Item -Path DellSmbios:\Security\PasswordBypass "Disabled"
Set-Item -Path DellSmbios:\Security\AdminSetupLockout "Enabled"
Set-Item -Path DellSmbios:\TPMSecurity\TpmSecurity "Enabled"
Set-Item -Path DellSmbios:\TPMSecurity\TpmActivation "Enabled"
Set-Item -Path DellSmbios:\PowerManagement\DeepSleepCtrl "Disabled"
Set-Item -Path DellSmbios:\PowerManagement\UsbWake "Enabled"
Set-Item -Path DellSmbios:\PowerManagement\WakeOnLan "LanWlan"
Set-Item -Path DellSmbios:\PowerManagement\BlockSleep "Enabled"
Set-Item -Path DellSmbios:\POSTBehavior\Fastboot "Auto"
Set-Item -Path DellSmbios:\Security\AdminPassword $pwd