<#
.SYNOPSIS
    Enables automatic timezone detection and time synchronization

.DESCRIPTION
    Configures Windows to automatically detect timezone and sync time by setting:
    
    1. Location Services consent for timezone detection to "Allow"
       HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location
    
    2. Automatic timezone update service to enabled (Start = 3)
       HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate
    
.NOTES
    FileName:    AutomaticTimezone_Remediation.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Windows 10/11
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Remediation successful
    - 1: Remediation failed
    
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

##Enter the type of the registry key for example DWord
$regtype = "DWORD"


New-ItemProperty -LiteralPath $regpath -Name $regname -Value $regvalue -PropertyType $regtype -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath $regpath2 -Name $regname2 -Value $regvalue2 -PropertyType $regtype -Force -ea SilentlyContinue;