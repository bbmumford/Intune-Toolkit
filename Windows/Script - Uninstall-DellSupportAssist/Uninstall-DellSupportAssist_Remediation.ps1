<#
.SYNOPSIS
    Uninstalls Dell SupportAssist from the system

.DESCRIPTION
    Removes Dell SupportAssist software by executing its uninstaller with
    silent parameters. Searches both 32-bit and 64-bit registry paths to
    locate the uninstall string.
    
    Removes vendor bloatware to improve system security and performance.
    
.NOTES
    FileName:    Uninstall-DellSupportAssist_Remediation.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Dell hardware with SupportAssist installed
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Remediation successful (SupportAssist uninstalled)
    - 1: Remediation failed
    
    Purpose:
    - Remove vendor bloatware
    - Reduce security attack surface
    - Improve system performance
    
    Change Log:
    v1.0 - Initial release
#>

$DellSA = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | 
              Where-Object {$_.DisplayName -eq 'Dell SupportAssist'} | 
              Select-Object -Property DisplayName, UninstallString

Write-Host $DellSA.UninstallString

try {
    if ($DellSA.UninstallString -match 'msiexec.exe') {
        # Extract the GUID from the UninstallString
        $null = $DellSA.UninstallString -match '{[A-F0-9-]+}'
        $guid = $matches[0]

        Write-Host "Removing Dell SupportAssist using msiexec..."
        Start-Process msiexec.exe -ArgumentList "/x $($guid) /qn" -Wait
    } elseif ($DellSA.UninstallString -match 'SupportAssistUninstaller.exe') {
        Write-Host "Removing Dell SupportAssist using SupportAssistUninstaller.exe..."
        Start-Process "$($DellSA.UninstallString)" -ArgumentList "/arp /S" -Wait
	} else {
        Write-Host "Unsupported uninstall method found."
        Exit 1
    }

    Write-Host "Dell SupportAssist successfully removed"
    Exit 0
} catch {
    Write-Error "Error removing Dell SupportAssist"
    Exit 1
}
