<#
.SYNOPSIS
    Detects disk errors on the system drive

.DESCRIPTION
    Checks the system drive (typically C:) for file system errors using
    Windows Error Checking utility. Scans for disk errors that may cause
    system instability or data corruption.
    
    Detection-only script that triggers remediation if disk errors are found.
    
.NOTES
    FileName:    Disk-Repair_Detection.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Windows 7/8/10/11
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (no disk errors detected)
    - 1: Non-Compliant (disk errors found - triggers repair)
    
    Purpose:
    - Proactive disk health monitoring
    - Prevent data corruption
    - Maintain system stability
    
    Change Log:
    v1.0 - Initial release
#>
$disk = ($env:SystemDrive).Substring(0,1)

$repair = repair-volume -DriveLetter $disk -scan -Verbose

write-output $repair

if ($repair -eq "NoErrorsfound") {
write-host "No issues"
Exit 0
}
else {
write-host "Needs checking"
exit 1
}