<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: DisableSyncDelay_Remediation.ps1
Description: Sets up Automatic Timezone and Time Sync
Release notes:
Version 1.0: Init
Run as: User
Context: 64 Bit
Frequency: Every Hour
#> 

$Path = "HKCU:\SOFTWARE\Microsoft\OneDrive\Accounts\Business1"
$Name = "TimerAutoMount"
$Type = "QWORD"
$Value = 1

Set-ItemProperty -Path $Path -Name $Name -Type $Type -Value $Value 
