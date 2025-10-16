<#
.SYNOPSIS
    Detects if personal Microsoft Teams (consumer) app is installed

.DESCRIPTION
    Checks for the presence of the personal/consumer Microsoft Teams application
    (MicrosoftTeams AppX package). This is separate from Microsoft Teams for Work/School.
    
    In enterprise environments, the personal Teams app may not be desired.
    
.NOTES
    FileName:    Uninstall-PrivateTeams_Detection.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 3.0+ (for Get-AppxPackage)
    - Run as: System
    - Context: 64 Bit
    - Windows 10/11
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (personal Teams not installed)
    - 1: Non-Compliant (personal Teams installed - triggers removal)
    
    Note:
    - This targets the consumer Teams app (AppX package)
    - Does not affect Microsoft Teams for Work/School
    
    Change Log:
    v1.0 - Initial release
#>

if ($null -eq (Get-AppxPackage -Name MicrosoftTeams -allusers)) {
	Write-Host "Private MS Teams client is not installed"
	exit 0
} Else {
	Write-Host "Private MS Teams client is installed"
	Exit 1
}
