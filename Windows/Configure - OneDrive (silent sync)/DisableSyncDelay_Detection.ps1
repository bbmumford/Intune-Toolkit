<#
.SYNOPSIS
    Detects if OneDrive sync delay is disabled for automatic mounting

.DESCRIPTION
    Checks if the OneDrive Business account registry setting 'TimerAutoMount' is
    set to 1 to enable automatic library mounting without delay.
    
    Validates:
    - OneDrive client is installed
    - OneDrive Business1 account is configured
    - TimerAutoMount registry value is set to 1
    
    Gracefully handles scenarios where OneDrive is not yet installed or configured.
    
.NOTES
    FileName:    DisableSyncDelay_Detection.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.1
    
    Requirements:
    - PowerShell 2.0+
    - Run as: User (HKCU registry context)
    - Context: 64 Bit
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (sync delay disabled)
    - 1: Non-Compliant (triggers remediation or OneDrive not ready)
    
    Registry Path:
    HKCU:\SOFTWARE\Microsoft\OneDrive\Accounts\Business1
    Value: TimerAutoMount = 1 (QWORD)
    
    Deployment:
    - Schedule: Every Hour (recommended)
    
    Change Log:
    v1.1 - Added OneDrive installation checks, better error messages
    v1.0 - Initial release
#> 

$Path = "HKCU:\SOFTWARE\Microsoft\OneDrive\Accounts\Business1"
$Name = "TimerAutoMount"
$Type = "QWORD"
$Value = 1

Try {
    # Check if OneDrive is installed and configured
    $OneDriveBasePath = "HKCU:\SOFTWARE\Microsoft\OneDrive"
    
    if (-not (Test-Path $OneDriveBasePath)) {
        Write-Output "OneDrive not installed or not configured for this user"
        Exit 1  # Non-compliant - OneDrive not ready
    }
    
    # Check if Business1 account exists
    if (-not (Test-Path $Path)) {
        Write-Output "OneDrive Business account not configured yet (path does not exist)"
        Exit 1  # Non-compliant - OneDrive account not set up
    }
    
    # Check the registry value
    $Registry = Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop | Select-Object -ExpandProperty $Name
    
    If ($Registry -eq $Value){
        Write-Output "Compliant: OneDrive sync delay is disabled (TimerAutoMount = $Registry)"
        Exit 0
    } 
    else {
        Write-Output "Not Compliant: TimerAutoMount is set to $Registry (expected $Value)"
        Exit 1
    }
} 
Catch {
    Write-Output "Not Compliant: Registry value '$Name' does not exist or error occurred - $($_.Exception.Message)"
    Exit 1
}
