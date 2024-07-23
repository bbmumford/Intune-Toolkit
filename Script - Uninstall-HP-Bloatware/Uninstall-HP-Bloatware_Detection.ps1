<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: Uninstall-HP-Bloatware_Detection.ps1
Description: 
Version 1.0: Init
Run as: User
Context: 64 Bit
#> 

if (Test-Path "C:\IntuneDependencies\Remove-HP-Bloatware_Detection.txt") { 
	Write-Output "File exists."
	Exit 0
	} 

else { 
	Write-Output "File does not exist." 
	Exit 1
	}