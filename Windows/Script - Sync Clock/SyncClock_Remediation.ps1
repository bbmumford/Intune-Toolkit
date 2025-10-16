<#
.SYNOPSIS
    Forces Windows Time service to synchronize system clock

.DESCRIPTION
    Ensures the Windows Time (W32Time) service is running and forces an
    immediate time synchronization with configured time servers.
    
    Process:
    1. Starts W32Time service if not running
    2. Forces immediate time synchronization using w32tm /resync
    
.NOTES
    FileName:    SyncClock_Remediation.ps1
    Author:      
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
    - 0: Remediation successful (clock synchronized)
    - 1: Remediation failed
    
    Importance:
    - Accurate time critical for authentication and security
    - Prevents certificate validation failures
    - Ensures accurate logging and auditing
    
    Change Log:
    v1.0 - Initial release
#>

# Start Windows Time service if not running
$service = Get-Service -Name W32Time -ErrorAction SilentlyContinue
if ($service.Status -ne "Running") {
    Start-Service -Name W32Time
}

# Force time synchronization
w32tm /resync /nowait
