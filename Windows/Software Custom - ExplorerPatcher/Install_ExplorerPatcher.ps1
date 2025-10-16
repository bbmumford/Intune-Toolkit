<#
.SYNOPSIS
    Installs ExplorerPatcher for Windows 11

.DESCRIPTION
    Installs ExplorerPatcher to customize Windows 11 user interface and
    restore Windows 10-style taskbar and UI elements.
    
    Runs the ExplorerPatcher setup executable and restarts Windows Explorer
    to apply changes.
    
.NOTES
    FileName:    Install_ExplorerPatcher.ps1
    Author:      William Buckley (BAMITS)
    Created:     2024-07-18
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Windows 11 only
    
    Exit Codes:
    - 0: Installation successful
    
    External Dependencies:
    - ep_setup.exe (must be in same directory)
    
    Impact:
    - Modifies Windows Explorer behavior
    - Restarts Windows Explorer (closes all Explorer windows)
    - Changes taskbar and Start menu appearance
    - Requires Windows 11 restart for full effect
    
    Change Log:
    v1.0 - Initial release (2024-07-18)
#>

$ErrorActionPreference= 'silentlycontinue'

ep_setup.exe

$processid = (Get-Process -Name explorer).Id

if ($processid -ne $null) {
    # Explorer Running
    exit 0
} else {
    # Explorer Not Running
    taskkill /f /im explorer.exe
    start explorer.exe
    exit 0
}