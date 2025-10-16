<#
.SYNOPSIS
    Detects if Windows Time service is running and clock is synchronized

.DESCRIPTION
    Checks if the Windows Time (W32Time) service is running and verifies that
    the system clock is properly synchronized with a time server.
    
    Identifies systems running on "Free-running System Clock" which indicates
    the clock is not synchronized and may drift over time.
    
.NOTES
    FileName:    SyncClock_Detection.ps1
    Author:      
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System
    - Context: 64 Bit
    - Windows 7/8/10/11
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (clock synchronized)
    - 1: Non-Compliant (clock not synchronized - triggers remediation)
    
    Importance:
    - Accurate time is critical for authentication (Kerberos)
    - Required for SSL/TLS certificate validation
    - Important for log timestamps and audit trails
    
    Change Log:
    v1.0 - Initial release
#>

# Check if the Windows Time service is running and synchronized
$service = Get-Service -Name W32Time -ErrorAction SilentlyContinue
$syncStatus = w32tm /query /status | Select-String "Source" | Out-String

if ($service.Status -eq "Running" -and $syncStatus -match "Free-running System Clock") {
    Write-Output "Clock not synchronized"
    Exit 1
} else {
    Write-Output "Clock synchronized"
    Exit 0
}
