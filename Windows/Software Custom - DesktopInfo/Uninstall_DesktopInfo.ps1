<#
.SYNOPSIS
    Uninstalls DesktopInfo system information overlay

.DESCRIPTION
    Removes DesktopInfo from the system by deleting installation folder
    and removing the scheduled task.
    
    Completely removes DesktopInfo overlay and all associated files.
    
.NOTES
    FileName:    Uninstall_DesktopInfo.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 5.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Windows 10/11
    
    Exit Codes:
    - 0: Uninstallation successful
    - 1: Uninstallation failed
    
    Impact:
    - Removes desktop information overlay
    - Deletes C:\Program Files\DesktopInfo\
    - Removes scheduled task
    - Desktop wallpaper returns to normal state
    
    Change Log:
    v1.0 - Initial release
#>

$PackageName = "DesktopInfo"
$Prg_path = "$Env:Programfiles\DesktopInfo"

Start-Transcript -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\$PackageName-uninstall.log" -Force

Remove-Item -Path "$Prg_path" -Force -Confirm:$false -Recurse
Unregister-ScheduledTask -TaskName $PackageName -Confirm:$false

Stop-Transcript