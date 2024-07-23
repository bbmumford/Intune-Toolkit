<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: Disk-Repair_Detection.ps1
Description: Checks for disk errors. All in one script.
Version 1.0: Init
Run as: System
Context: 64 Bit
#> 
$disk = ($env:SystemDrive).Substring(0,1)

$repair = repair-volume -DriveLetter $disk -scan -Verbose

write-output $repair

if ($repair -eq "NoErrorsfound") {
write-host "No issues"
Exit 0
}
else {
write-host "Needs checking"
exit 1
}