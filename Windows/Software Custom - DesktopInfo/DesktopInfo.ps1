<#
.SYNOPSIS
    Launches DesktopInfo with configuration

.DESCRIPTION
    Starts DesktopInfo64.exe with the specified INI configuration file
    to display system information overlay on desktop.
    
    This script is typically called by the scheduled task at user logon.
    
.NOTES
    FileName:    DesktopInfo.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: User
    - Context: 64 Bit
    - Windows 10/11
    - DesktopInfo must be installed
    
    Configuration:
    - Uses hostname.ini configuration file
    - Logs to: C:\Program Files\DesktopInfo\DesktopInfo-lastrun.log
    
    Usage:
    Called automatically by scheduled task at logon
    
    Change Log:
    v1.0 - Initial release
#>

$Prg_path = "$Env:Programfiles\DesktopInfo"
Start-Transcript -Path "$Prg_path\DesktopInfo-lastrun.log" -Force

Write-Host "Starte DesktopInfo"
Start-Process -FilePath "$Prg_path\DesktopInfo64.exe" -ArgumentList "/ini=hostname.ini"

Stop-Transcript

