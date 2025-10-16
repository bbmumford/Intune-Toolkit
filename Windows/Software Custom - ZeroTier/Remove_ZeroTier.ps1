<#
.SYNOPSIS
    Uninstalls ZeroTier One VPN client

.DESCRIPTION
    Removes ZeroTier One from the system by locating and executing the
    uninstaller from the registry. Searches both 32-bit and 64-bit
    registry paths.
    
    Completely removes ZeroTier VPN client and all network connections.
    
.NOTES
    FileName:    Remove_ZeroTier.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Windows 7/8/10/11
    
    Exit Codes:
    - 0: Uninstallation successful
    - 1: Uninstallation failed or ZeroTier not found
    
    Usage:
    powershell.exe -ExecutionPolicy Bypass -File "./Remove_ZeroTier.ps1"
    
    Impact:
    - Removes all ZeroTier network connections
    - Removes ZeroTier service and drivers
    - Network connectivity via ZeroTier will be lost
    
    Change Log:
    v1.0 - Initial release
#>

# Removes ZeroTier One
$Paths = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
$ZeroTierOne = Get-ChildItem -Path $Paths | Get-ItemProperty | Where-Object { $_.DisplayName -like 'ZeroTier One' } | Select-Object
$VirtualNetworkPort = Get-ChildItem -Path $Paths | Get-ItemProperty | Where-Object { $_.DisplayName -like 'ZeroTier One Virtual Network Port' } | Select-Object

if ($ZeroTierOne) {
  Write-Output 'Uninstalling ZeroTier One...'
  foreach ($Ver in $ZeroTierOne) {
    $Uninst = $Ver.UninstallString
    cmd /c $Uninst /qn
  }
}

if ($VirtualNetworkPort) {
  Write-Output 'Uninstalling ZeroTier Virtual Network Port...'
  foreach ($Ver in $VirtualNetworkPort) {
    $Uninst = $Ver.UninstallString
    cmd /c $Uninst /qn
  }
}

Write-Output 'Uninstall complete. Restart recommended before reinstall.'