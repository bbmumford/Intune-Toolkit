<#
.SYNOPSIS
    Detects if New Microsoft Teams is installed

.DESCRIPTION
    Checks if the new Microsoft Teams (Teams 2.0) client is installed on
    the system by scanning the WindowsApps folder for Teams packages.
    
    Validates presence of MSTeams_* packages to confirm installation.
    
.NOTES
    FileName:    NewMicrosoftTeams_Detection.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System
    - Context: 64 Bit
    - Windows 10 1809+ or Windows 11
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (Teams 2.0 installed)
    - 1: Non-Compliant (Teams 2.0 not found)
    
    Change Log:
    v1.0 - Initial release
#>

# Define the path where New Microsoft Teams is installed
$teamsPath = "C:\Program Files\WindowsApps"

# Define the filter pattern for Microsoft Teams installer
$teamsInstallerName = "MSTeams_*"

# Retrieve items in the specified path matching the filter pattern
$teamsNew = Get-ChildItem -Path $teamsPath -Filter $teamsInstallerName

# Check if Microsoft Teams is installed
if ($teamsNew) {
    # Display message if Microsoft Teams is found
    Write-Host "New Microsoft Teams client is installed."
    exit 0
} else {
    # Display message if Microsoft Teams is not found
    Write-Host "Microsoft Teams client not found."
    exit 1
}
