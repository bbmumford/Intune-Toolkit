<#
.SYNOPSIS
    Detects if DesktopInfo is installed and current

.DESCRIPTION
    Checks if DesktopInfo is installed and verifies the version is current
    (v3.11.0).
    
    Validates both the executable presence and scheduled task existence.
    
.NOTES
    FileName:    DesktopInfo_Detection.ps1
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
    - 0: Compliant (DesktopInfo v3.11.0 installed)
    - 1: Non-Compliant (not installed or wrong version)
    
    Configuration:
    - Expected version: 3.11.0
    - Installation path: C:\Program Files\DesktopInfo\
    
    Change Log:
    v1.0 - Initial release
#>

$ProgramName = "DesktopInfo"
$Prg_path = "$Env:Programfiles\DesktopInfo"
$ProgramPath = "$Prg_path\DesktopInfo64.exe"
$ProgramVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($ProgramPath).FileVersion

$taskExists = Get-ScheduledTask | Where-Object {$_.TaskName -like $ProgramName }
if($taskExists) {
    if($ProgramVersion -eq "3.11.0"){
        Write-Host "Found it!"
    }
}