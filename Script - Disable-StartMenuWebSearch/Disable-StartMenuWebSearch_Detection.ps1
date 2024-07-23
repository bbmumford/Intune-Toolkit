<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: Disable-StartMenuWebSearch_Detection.ps1
Description: 
Version 1.0: Init
Run as: System
Context: 64 Bit
#> 

$Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
$Name = "BingSearchEnabled"
$Value = 0

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