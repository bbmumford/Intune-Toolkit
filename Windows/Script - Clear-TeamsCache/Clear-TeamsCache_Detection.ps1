<#
.SYNOPSIS
    Detects if Microsoft Teams cache needs to be cleared

.DESCRIPTION
    Checks if the Microsoft Teams cache folder exists in the user's AppData.
    Used to trigger cache clearing remediation when Teams performance issues occur.
    
.NOTES
    FileName:    Clear-TeamsCache_Detection.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: User (APPDATA context)
    - Context: 64 Bit
    - Microsoft Teams (Classic or New)
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (cache does not need clearing)
    - 1: Non-Compliant (triggers cache clearing)
    
    Use Cases:
    - Teams performance degradation
    - Login or sync issues
    - Corrupt cache data
    
    Change Log:
    v1.0 - Initial release
#>

if(Test-Path -Path $env:APPDATA\"Microsoft\teams"){
    return 1
}else{
    return 0
}
