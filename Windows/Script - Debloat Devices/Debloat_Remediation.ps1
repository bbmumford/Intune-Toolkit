<#
.SYNOPSIS
    Removes Windows bloatware and configures clean Windows experience

.DESCRIPTION
    Executes comprehensive Windows debloat process using two community-trusted
    scripts:
    1. Raphire's Win11Debloat - Removes built-in apps, disables telemetry,
       configures taskbar, and removes various bloatware features
    2. Andrew S Taylor's RemoveBloat - Additional bloatware removal
    
    Creates registry marker upon completion for detection tracking.
    
.NOTES
    FileName:    Debloat_Remediation.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 5.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Windows 10/11
    - Internet connection required
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Remediation successful
    - 1: Remediation failed
    
    External Dependencies:
    - Raphire's Win11Debloat (GitHub: Raphire/Win11Debloat)
    - Andrew S Taylor's RemoveBloat (GitHub: andrew-s-taylor/public)
    
    Impact:
    - Removes Microsoft Store apps (Comm, Dev, Gaming)
    - Disables telemetry and Bing integration
    - Configures taskbar (left-aligned, hide search/taskview)
    - Disables Copilot, Recall, Widgets, Chat
    - Shows hidden folders, hides 3D Objects/Music
    - Process can take 10-15 minutes
    
    Security/Privacy:
    - Disables Windows telemetry
    - Removes data collection features
    - Improves privacy posture
    
    Change Log:
    v1.0 - Initial release
#>

# Execute the debloat script
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/Raphire/Win11Debloat/master/Get.ps1"))) -RemoveCommApps -RemoveDevApps -RemoveGamingApps -DisableDVR -ClearStartAllUsers -DisableTelemetry -DisableBing -DisableSuggestions -TaskbarAlignLeft -HideSearchTb -HideTaskview -ShowHiddenFolders -HideChat -DisableWidgets -DisableCopilot -DisableRecall -HideGallery -Hide3dObjects -HideMusic -Silent
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/andrew-s-taylor/public/refs/heads/main/De-Bloat/RemoveBloat.ps1")))

# Create the registry key and set a DWORD value to indicate completion
New-Item -Path "HKLM:\Software\Intune" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\Software\Intune" -Name "RaphireDebloatCompleted" -Value $true -Force
