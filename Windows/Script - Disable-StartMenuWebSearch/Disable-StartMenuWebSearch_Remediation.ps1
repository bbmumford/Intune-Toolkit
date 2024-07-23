<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: Disable-StartMenuWebSearch_Remediation.ps1
Description: 
Version 1.0: Init
Run as: System
Context: 64 Bit
#> 

$Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
$Name = "BingSearchEnabled"
$Type = "DWORD"
$Value = 0

New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force -ea SilentlyContinue;