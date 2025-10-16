<#
.SYNOPSIS
    Disables OneDrive sync delay for automatic library mounting

.DESCRIPTION
    Sets the OneDrive Business account registry value 'TimerAutoMount' to 1
    to enable automatic library mounting without delay.
    
    Process:
    1. Verifies OneDrive client is installed
    2. Creates registry path if OneDrive Business1 account path doesn't exist
    3. Sets TimerAutoMount value to 1
    4. Verifies the change was successful
    
    Gracefully handles scenarios where OneDrive is not yet installed.
    Will not attempt remediation if OneDrive client is missing.
    
.NOTES
    FileName:    DisableSyncDelay_Remediation.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.1
    
    Requirements:
    - PowerShell 2.0+
    - Run as: User (HKCU registry context)
    - Context: 64 Bit
    - OneDrive client installed
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Remediation successful (sync delay disabled)
    - 1: Remediation failed (OneDrive not ready or error occurred)
    
    Registry Path:
    HKCU:\SOFTWARE\Microsoft\OneDrive\Accounts\Business1
    Value: TimerAutoMount = 1 (QWORD)
    
    Deployment:
    - Schedule: Every Hour (recommended)
    
    Change Log:
    v1.1 - Added OneDrive checks, auto-creates registry path, verification step
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
        Write-Output "OneDrive not installed or not configured for this user. Remediation cannot proceed."
        Exit 1  # Cannot remediate - OneDrive not ready
    }
    
    # Check if Business1 account path exists, create if it doesn't
    if (-not (Test-Path $Path)) {
        Write-Output "OneDrive Business account path does not exist. Creating registry path..."
        New-Item -Path $Path -Force -ErrorAction Stop | Out-Null
        Write-Output "Registry path created: $Path"
    }
    
    # Set the registry value
    Set-ItemProperty -Path $Path -Name $Name -Type $Type -Value $Value -ErrorAction Stop
    
    # Verify the change
    $VerifyValue = Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop | Select-Object -ExpandProperty $Name
    
    if ($VerifyValue -eq $Value) {
        Write-Output "Successfully set $Name to $Value in $Path"
        Exit 0
    }
    else {
        Write-Output "Failed to verify registry value. Expected $Value, got $VerifyValue"
        Exit 1
    }
}
Catch {
    Write-Output "Remediation failed: $($_.Exception.Message)"
    Exit 1
} 
