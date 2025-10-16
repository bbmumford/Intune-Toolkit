<#
.SYNOPSIS
    Detects if device auto-sync schedule is configured

.DESCRIPTION
    Checks if the scheduled task for automatic device synchronization with Intune
    is properly configured and running. Monitors the PushLaunch task to ensure
    regular sync intervals are maintained.
    
.NOTES
    FileName:    AutoSync_Detection.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System
    - Context: 64 Bit
    - Windows 10/11
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (auto-sync configured and running)
    - 1: Non-Compliant (triggers remediation)
    
    Change Log:
    v1.0 - Initial release
#>

# Create variable for the time of the last Intune sync.
$PushInfo = Get-ScheduledTask -TaskName PushLaunch | Get-ScheduledTaskInfo
$LastPush = $PushInfo.LastRunTime
$CurrentTime=(GET-DATE)

# Calculate the time difference between the current date/time and the date stored in the variable.
$TimeDiff = New-TimeSpan -Start $LastPush -End $CurrentTime

# If/Else statement checking whether the Time Difference between the Last Sync and the current time is less or greater than 2 days
if ($TimeDiff.Days -gt 2) {
    # The time difference is more than 2 days
    Write-Host "Last Sync was more than 2 days ago"
    Exit 1
} else {
    # The time difference is less than 2 days
    Write-Host "Sync Complete"
    Exit 0
}
