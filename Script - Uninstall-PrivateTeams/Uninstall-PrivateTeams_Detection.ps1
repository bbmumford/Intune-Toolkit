<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: Uninstall-PrivateTeams.ps1
Description:
Version 1.0: Init
Run as: System
Context: 64 Bit
#> 

if ($null -eq (Get-AppxPackage -Name MicrosoftTeams -allusers)) {
	Write-Host "Private MS Teams client is not installed"
	exit 0
} Else {
	Write-Host "Private MS Teams client is installed"
	Exit 1
}
