<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: CSSC.ps1
Description: Common Security Score Compliance Script
Version 1.0: unique file name
Run as: System
Context: 64 Bit
#>

# Define a function to check and set registry keys
function Set-RegistryValue {
    param (
        [string]$Path,
        [string]$Name,
        [string]$Value,
        [string]$Type = "String"
    )
    try {
        if ($Type -eq "DWord") {
            Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type DWord -Force
        } else {
            Set-ItemProperty -Path $Path -Name $Name -Value $Value -Force
        }
        Write-Host "Set registry key: $Path\$Name to $Value"
    } catch {
        Write-Host "Failed to set registry key: $Path\$Name - $_"
    }
}

# 1. Ensure Windows Defender Antivirus is enabled
Set-Service -Name "WinDefend" -StartupType Automatic
Start-Service -Name "WinDefend"

# 2. Enable Windows Defender Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# 3. Set Password Policy
$Policy = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Set-RegistryValue -Path $Policy -Name "MinimumPasswordLength" -Value 12 -Type "DWord" # Minimum password length
Set-RegistryValue -Path $Policy -Name "MaximumPasswordAge" -Value 30 -Type "DWord" # Maximum password age (days)
Set-RegistryValue -Path $Policy -Name "LockoutBadCount" -Value 5 -Type "DWord" # Lockout after bad attempts
Set-RegistryValue -Path $Policy -Name "ResetLockoutCount" -Value 15 -Type "DWord" # Lockout reset time (minutes)

# 4. Enable BitLocker on operating system drives
Enable-BitLocker -MountPoint "C:" -EncryptionMethod Aes256 -UsedSpaceOnly -Password (ConvertTo-SecureString "YourPasswordHere" -AsPlainText -Force)

# 5. Configure Windows Update settings
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Value 4 -Type "DWord" # 4 = Auto download and notify for install
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "ScheduledInstallDay" -Value 0 -Type "DWord" # Every day
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "ScheduledInstallTime" -Value 3 -Type "DWord" # 3 AM

# 6. Disable SMBv1
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SMB1" -Value 0 -Type "DWord"

# 7. Enable User Account Control (UAC)
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 1 -Type "DWord"

# 8. Enable auditing for logon events
$AuditPolPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit"
Set-RegistryValue -Path $AuditPolPath -Name "AuditLogon" -Value 1 -Type "DWord"

# 9. Disable unnecessary services
$servicesToDisable = @(
    "XblGameSave",
    "WMPNetworkSvc",
    "HomeGroupListener",
    "HomeGroupProvider"
)

foreach ($service in $servicesToDisable) {
    try {
        Stop-Service -Name $service -Force
        Set-Service -Name $service -StartupType Disabled
        Write-Host "Disabled service: $service"
    } catch {
        Write-Host "Failed to disable service: $service - $_"
    }
}
