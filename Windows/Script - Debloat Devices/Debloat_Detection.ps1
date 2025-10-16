<#
.SYNOPSIS
    Detects if Windows debloat has been completed

.DESCRIPTION
    Checks registry to determine if the Windows debloat process (using
    Raphire's Win11Debloat and Andrew S Taylor's RemoveBloat scripts) has
    been successfully completed.
    
    Validates presence of RaphireDebloatCompleted registry marker.
    
.NOTES
    FileName:    Debloat_Detection.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 5.0+
    - Run as: System
    - Context: 64 Bit
    - Windows 10/11
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (debloat completed)
    - 1: Non-Compliant (debloat not completed)
    
    Registry Path:
    - HKLM:\Software\IntuneDependencies\RaphireDebloatCompleted
    
    Change Log:
    v1.0 - Initial release
#>

# Detection script to check if the DWORD registry value exists and is set to $true
$regPath = "HKLM:\Software\IntuneDependencies"
$regName = "RaphireDebloatCompleted"

if ((Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue).$regName -eq $true) {
    Write-Output "RaphireDebloatCompleted is set to $true."
    Exit 0
} else {
    Write-Output "RaphireDebloatCompleted is not set to $true or does not exist."
    Exit 1
}
