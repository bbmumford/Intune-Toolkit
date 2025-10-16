<#
.SYNOPSIS
    Detects if automatic timezone detection and time synchronization are enabled

.DESCRIPTION
    Checks if Windows is configured to automatically detect timezone and sync time.
    
    Validates two registry settings:
    1. Location Services consent for timezone detection
       HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location
       Value: Allow
    
    2. Automatic timezone update service
       HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate
       Start: 3 (Manual/Automatic)
    
.NOTES
    FileName:    AutomaticTimezone_Detection.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System
    - Context: 64 Bit
    - Windows 10/11
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (automatic timezone enabled)
    - 1: Non-Compliant (triggers remediation)
    
    Change Log:
    v1.0 - Initial release
#> 

##Enter the path to the registry key for example HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System
$regpath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
$regpath2 = "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate"
##Enter the name of the registry key for example EnableLUA
$regname = "Value"
$regname2 = "start"
##Enter the value of the registry key we are checking for, for example 0
$regvalue = "Allow"
$regvalue2 = "3"


Try {
    $Registry = Get-ItemProperty -Path $regpath -Name $regname -ErrorAction Stop | Select-Object -ExpandProperty $regname
    $Registry2 = Get-ItemProperty -Path $regpath2 -Name $regname2 -ErrorAction Stop | Select-Object -ExpandProperty $regname2
    If (($Registry -eq $regvalue) -and ($Registry2 -eq $regvalue2)) {
        Write-Output "Compliant"
        Exit 0
    }
    else {
        Write-Warning "Not Compliant"
        Exit 1

    }
    

} 
Catch {
    Write-Warning "Not Compliant"
    Exit 1
}