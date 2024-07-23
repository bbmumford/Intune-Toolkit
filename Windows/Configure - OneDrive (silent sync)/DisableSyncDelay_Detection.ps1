<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: DisableSyncDelay_Detection.ps1
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

Try {
    $Registry = Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop | Select-Object -ExpandProperty $Name
    If ($Registry -eq $Value){
        Write-Output "Compliant"
        Exit 0
    } 
    Write-Warning "Not Compliant"
    Exit 1
} 
Catch {
    Write-Warning "Not Compliant"
    Exit 1
}
