<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: Install_ZeroTier.ps1
Description: Install & join ZeroTier network.
Version 1.0: Init
Run as: System
Context: 64 Bit
#> 

param (
  [string]$Token, # Get Zerotier API Token
  [string]$NetworkID, # Get Zerotier Network ID
  [switch]$UI, # Installs ZeroTier UI
  [switch]$DisableDNS, # Disables ZeroTier DNS management
  [switch]$GlobalRoutes, # Allows ZeroTier managed routes to overlap public IP space
  [switch]$DefaultRoute # Allows ZeroTier to override system default route (full tunnel)
)

if (!$Token -or !$NetworkID) { 
  throw "This script requires a ZeroTier API token and Network ID."
}

$DownloadURL = 'https://download.zerotier.com/dist/ZeroTier%20One.msi'
$Installer = "$env:temp\ZeroTierOne.msi"
$CLI = 'C:\Program Files (x86)\ZeroTier\One\zerotier-cli.bat'

# Check for required PowerShell version (7+)
if (!($PSVersionTable.PSVersion.Major -ge 7)) {
  try {
    
    # Install PowerShell 7 if missing
    if (!(Test-Path "$env:SystemDrive\Program Files\PowerShell\7")) {
      Write-Output 'Installing PowerShell version 7...'
      Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI -Quiet"
    }

    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
    
    # Restart script in PowerShell 7
    pwsh -File "`"$PSCommandPath`"" @PSBoundParameters
    
  }
  catch {
    Write-Output 'PowerShell 7 was not installed. Update PowerShell and try again.'
    throw $Error
  }
  finally { exit $LASTEXITCODE }
}
else { $PSStyle.OutputRendering = 'PlainText' }

try {
  Write-Output 'Downloading ZeroTier...'
  Invoke-WebRequest -Uri $DownloadURL -OutFile $Installer
    
  Write-Output 'Installing ZeroTier...'
  if ($UI) {
    # Install & close ui
    cmd /c msiexec /i $Installer /qn /norestart
    Stop-Process -Name 'zerotier_desktop_ui' -Force -ErrorAction Ignore
  }
  else {
    # Install & unhide from installed programs list
    cmd /c msiexec /i $Installer /qn /norestart 'ZTHEADLESS=Yes'
    $Paths = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
    $RegKey = Get-ChildItem -Path $Paths | Get-ItemProperty | Where-Object { $_.DisplayName -like 'ZeroTier One' } | Select-Object
    Remove-ItemProperty -Path $RegKey.PSPath -Name 'SystemComponent' -ErrorAction Ignore

  }
  
  # Get Node ID
  $NodeID = (cmd /c $CLI info).split(' ')[2]
   
  # API Member object properties
  $Member = @{
    name = $env:COMPUTERNAME
    description = ''
    config = @{ authorized = $True }
  } | ConvertTo-Json
  
  # Prepare API request
  $Params = @{
    Method = 'Post'
    Uri = "https://my.zerotier.com/api/network/$NetworkID/member/$NodeID"
    Body = $Member
    Authentication = 'Bearer'
    Token = ConvertTo-SecureString $Token -AsPlainText -Force
    MaximumRetryCount = 3
    RetryIntervalSec = 5
  }
  
  # Join network
  Write-Output "Configuring ZeroTier network $NetworkID as $NodeID..."
  Invoke-RestMethod @Params
      
  # Configure ZeroTier client
  if (!($DisableDNS)) { cmd /c $CLI set $NetworkID allowDNS=1 | Out-Null }
  if ($GlobalRoutes) { cmd /c $CLI set $NetworkID allowGlobal=1 | Out-Null }
  if ($DefaultRoute) { cmd /c $CLI set $NetworkID allowDefault=1 | Out-Null }
}
catch { throw $Error }
finally { Remove-Item $Installer -Force -ErrorAction Ignore }
