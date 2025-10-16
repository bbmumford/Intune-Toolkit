<#
.SYNOPSIS
    Updates ZeroTier One to the latest version

.DESCRIPTION
    Downloads and installs the latest version of ZeroTier One VPN client.
    Can run in headless mode for silent updates without user interaction.
    
    Preserves existing network connections and configuration during update.
    
    Parameters:
    - $Headless: Optional switch for silent/unattended installation
    
.NOTES
    FileName:    Update_ZeroTier.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Internet connection required
    - Windows 7/8/10/11
    - ZeroTier One already installed
    
    Exit Codes:
    - 0: Update successful
    - 1: Update failed
    
    Usage:
    powershell.exe -ExecutionPolicy Bypass -File "./Update_ZeroTier.ps1" -Headless
    
    Impact:
    - Temporarily disconnects ZeroTier networks during update
    - Preserves network memberships and configuration
    - May require brief service restart
    
    Change Log:
    v1.0 - Initial release
#>

param ([switch]$Headless ) # Run msi in headless mode

$DownloadURL = 'https://download.zerotier.com/dist/ZeroTier%20One.msi'
$Installer = "$env:temp\ZeroTierOne.msi"
$Paths = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
$RegKey = Get-ChildItem -Path $Paths | Get-ItemProperty | Where-Object { $_.DisplayName -like 'ZeroTier One' } | Select-Object

if ($RegKey) {
  try {
    # Set PowerShell to TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  
    Write-Output 'Downloading ZeroTier...'
    Invoke-WebRequest -Uri $DownloadURL -OutFile $Installer
    
    Write-Output 'Installing ZeroTier...'
    if ($Headless) {
      # Install & unhide from installed programs list
      cmd /c msiexec /i $Installer /qn /norestart 'ZTHEADLESS=Yes'
      $RegKey = Get-ChildItem -Path $Paths | Get-ItemProperty | Where-Object { $_.DisplayName -like 'ZeroTier One' } | Select-Object
      Remove-ItemProperty -Path $RegKey.PSPath -Name 'SystemComponent' -ErrorAction Ignore
    }
    else {
      # Install & close ui
      cmd /c msiexec /i $Installer /qn /norestart
      Stop-Process -Name 'zerotier_desktop_ui' -Force -ErrorAction Ignore
    }
  }
  catch { throw $Error }
  finally { Remove-Item $Installer -Force -ErrorAction Ignore }
}
else {
  Write-Output 'ZeroTier was not installed.'
}