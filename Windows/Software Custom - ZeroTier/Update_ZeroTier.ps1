<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: Update_ZeroTier.ps1
Description: Update ZeroTier.
Version 1.0: Init
Run as: System
Context: 64 Bit
Note: run with
    powershell.exe -ExecutionPolicy Bypass -File "./Update_ZeroTier.ps1" -Headless
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