<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: Disable-SMBv1_Remediation.ps1
Description: Disables SMBv1 via registry key
Version 1.0: Init
Run as: System
Context: 64 Bit
#> 

Set-SmbServerConfiguration -EnableSMB1Protocol 0