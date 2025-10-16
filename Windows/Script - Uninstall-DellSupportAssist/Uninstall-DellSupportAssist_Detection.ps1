<#
.SYNOPSIS
    Detects if Dell SupportAssist is installed on the system

.DESCRIPTION
    Checks for the presence of Dell SupportAssist software by querying
    installed applications. Dell SupportAssist is vendor bloatware that
    may not be desired in enterprise environments.
    
.NOTES
    FileName:    Uninstall-DellSupportAssist_Detection.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System
    - Context: 64 Bit
    - Dell hardware
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (SupportAssist not installed)
    - 1: Non-Compliant (SupportAssist installed - triggers removal)
    
    Purpose:
    - Remove vendor bloatware
    - Reduce security attack surface
    - Improve system performance
    
    Change Log:
    v1.0 - Initial release
#>

Try {
    $DellSA = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | 
              Where-Object {$_.DisplayName -eq 'Dell SupportAssist'} | 
              Select-Object -Property DisplayName, UninstallString

    if ($DellSA) {
        $installed = $true
        $uninstallString = $DellSA.UninstallString
    } else {
        $installed = $false
    }

    if ($installed) {
        Write-Output "Not Compliant"
        Write-Output "Uninstall String: $uninstallString"
        Exit 1
    } else {
        Write-Output "Compliant"
        Exit 0
    }
} 
Catch {
    Write-Warning "Not Compliant"
    Exit 1
}
