<#
.SYNOPSIS
    Detects if WSL is installed and configured

.DESCRIPTION
    Checks if Windows Subsystem for Linux (WSL) is enabled, Virtual Machine
    Platform is enabled, and Ubuntu distribution is installed.
    
    Validates complete WSL installation including default distribution.
    
.NOTES
    FileName:    Detection.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 5.0+
    - Run as: System
    - Context: 64 Bit
    - Windows 10 2004+ or Windows 11
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (WSL, VM Platform, and Ubuntu installed)
    - 1: Non-Compliant (one or more components missing)
    
    Change Log:
    v1.0 - Initial release
#>

# Check if WSL is enabled
$WSLFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
$VMFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform

# Check for default Linux distribution (Ubuntu)
$DistroInstalled = Get-AppxPackage -Name "CanonicalGroupLimited.Ubuntu" -ErrorAction SilentlyContinue

if ($WSLFeature.State -eq "Enabled" -and $VMFeature.State -eq "Enabled" -and $DistroInstalled) {
    # WSL and Ubuntu are installed
    exit 0
} else {
    # WSL and/or Ubuntu are not installed
    exit 1
}
