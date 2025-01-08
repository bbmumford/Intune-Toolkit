<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: Disable-SMBv1_Detection.ps1
Description: Detects if SMBv1 is enabled
Version 1.0: Init
Run as: System
Context: 64 Bit
#> 

$smbv1 = get-smbserverconfiguration | Select-Object -ExpandProperty EnableSMB1Protocol
if ($smbv1 -eq $false) {
    write-host "SMBv1 is disabled"
    exit 0
}
else {
    write-host "SMBv1 is enabled"
    exit 1
}