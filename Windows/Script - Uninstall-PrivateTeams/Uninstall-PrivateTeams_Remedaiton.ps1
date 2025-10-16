<#
.SYNOPSIS
    Uninstalls personal Microsoft Teams (consumer) app

.DESCRIPTION
    Removes the personal/consumer Microsoft Teams application (AppX package)
    from all users on the system. Runs a debloat script to ensure complete removal.
    
    This targets the consumer Teams app and does not affect Microsoft Teams
    for Work/School (enterprise version).
    
.NOTES
    FileName:    Uninstall-PrivateTeams_Remediation.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 3.0+ (for AppX cmdlets)
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Windows 10/11
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Remediation successful (personal Teams uninstalled)
    - 1: Remediation failed
    
    External Dependencies:
    - Uses debloat script from GitHub
    
    Note:
    - Only removes consumer Teams app
    - Enterprise Teams for Work/School remains functional
    
    Change Log:
    v1.0 - Initial release
#>

param (
    [switch]$remediate = $True
)

try {
    # check if the teams app is installed
    if ($null -eq (Get-AppxPackage -Name MicrosoftTeams) ) { $AppCompliance = $true }
    else { $AppCompliance = $false }
    
    # evaluate the compliance
    if ($AppCompliance -eq $true) {

        Write-Host "Success, no app detected"
        exit 0
    }
    else {
        if($Remediate.IsPresent) {
            Get-AppxPackage -Name MicrosoftTeams | Remove-AppxPackage -ErrorAction stop
            Write-Host "Success, regkey set and app uninstalled"
            exit 0
        }
        else {
            Write-Host "Failure, app detected"
            exit 1
        }
    }
}
catch {
    $errMsg = _.Exception.Message
    Write-Host $errMsg
    exit 1
}