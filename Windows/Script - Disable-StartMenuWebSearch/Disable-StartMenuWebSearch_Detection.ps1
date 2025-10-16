<#
.SYNOPSIS
    Detects if Start Menu web search is disabled

.DESCRIPTION
    Checks if Windows Start Menu web search (Bing integration) is disabled
    by verifying the BingSearchEnabled registry value.
    
    Registry Path:
    HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search
    
.NOTES
    FileName:    Disable-StartMenuWebSearch_Detection.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System
    - Context: 64 Bit
    - Windows 10/11
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (web search disabled)
    - 1: Non-Compliant (triggers remediation)
    
    Privacy:
    - Disabling prevents search queries from being sent to Bing
    - Improves user privacy
    
    Change Log:
    v1.0 - Initial release
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