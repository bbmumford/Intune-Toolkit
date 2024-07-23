<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: AutoSync_Remediation.ps1
Description: 
Version 1.0: Init
Run as: System
Context: 64 Bit
#> 

try {
    Get-ScheduledTask | ? {$_.TaskName -eq 'PushLaunch'} | Start-ScheduledTask
    Exit 0
}
catch {
    Write-Error $_
    Exit 1
}
