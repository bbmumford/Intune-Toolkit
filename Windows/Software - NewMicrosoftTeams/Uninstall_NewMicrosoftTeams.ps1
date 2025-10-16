<#
.SYNOPSIS
    Uninstalls New Microsoft Teams (Teams 2.0)

.DESCRIPTION
    Removes the new Microsoft Teams client using the Teams Bootstrapper
    uninstall method.
    
    Completely removes Teams 2.0 from the system for all users.
    
.NOTES
    FileName:    Uninstall_NewMicrosoftTeams.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Windows 10 1809+ or Windows 11
    
    Exit Codes:
    - 0: Uninstallation successful
    - 1: Uninstallation failed
    
    External Dependencies:
    - teamsbootstrapper.exe (must be in same directory)
    
    Usage:
    ./teamsbootstrapper -x
    
    Change Log:
    v1.0 - Initial release
#>

./teamsbootstrapper -x
