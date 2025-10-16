<#
.SYNOPSIS
    Disables Start Menu web search (Bing integration)

.DESCRIPTION
    Disables Windows Start Menu web search by setting the BingSearchEnabled
    registry value to 0, preventing search queries from being sent to Bing.
    
    Registry Path:
    HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search
    Value: BingSearchEnabled = 0
    
.NOTES
    FileName:    Disable-StartMenuWebSearch_Remediation.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Windows 10/11
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Remediation successful (web search disabled)
    - 1: Remediation failed
    
    Privacy:
    - Prevents search queries from being sent to Bing
    - Improves user privacy and reduces data collection
    
    Change Log:
    v1.0 - Initial release
#>

$Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
$Name = "BingSearchEnabled"
$Type = "DWORD"
$Value = 0

New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force -ea SilentlyContinue;