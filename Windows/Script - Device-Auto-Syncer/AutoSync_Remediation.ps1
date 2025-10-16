<#
.SYNOPSIS
    Configures automatic device synchronization with Intune

.DESCRIPTION
    Triggers an immediate Intune sync and ensures the PushLaunch scheduled task
    is properly configured for automatic device management policy synchronization.
    
.NOTES
    FileName:    AutoSync_Remediation.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Windows 10/11
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Remediation successful
    - 1: Remediation failed
    
    Change Log:
    v1.0 - Initial release
#>

try {
    Get-ScheduledTask | ? {$_.TaskName -eq 'PushLaunch'} | Start-ScheduledTask
    Exit 0
}
catch {
    Write-Error $_
    Exit 1
}
