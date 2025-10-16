<#
.SYNOPSIS
    Detects if HP bloatware is present on the system

.DESCRIPTION
    Checks for the presence of HP bloatware applications including:
    - HP AppX packages (HP Support Assistant, HP Privacy Settings, etc.)
    - HP provisioned packages
    - HP installed programs (HP Connection Optimizer, HP Wolf Security, etc.)
    
    If any HP bloatware is found, triggers remediation for removal.
    
.NOTES
    FileName:    Uninstall-HP-Bloatware_Detection.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-17
    Version:     2.0
    
    Requirements:
    - PowerShell 5.0+
    - Run as: System
    - Context: 64 Bit
    - HP hardware
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (no HP bloatware found)
    - 1: Non-Compliant (HP bloatware detected - triggers removal)
    
    Purpose:
    - Detect vendor bloatware
    - Trigger removal when bloatware is present
    - Improve system performance
    - Reduce security attack surface
    
    Change Log:
    v2.0 - Changed to detect actual bloatware presence instead of completion marker
    v1.1 - Migrated to registry-based detection
    v1.0 - Initial release
#>

#region Configuration
# Define HP bloatware to detect
$UninstallPackages = @(
    "AD2F1837.HPJumpStarts"
    "AD2F1837.HPPCHardwareDiagnosticsWindows"
    "AD2F1837.HPPowerManager"
    "AD2F1837.HPPrivacySettings"
    "AD2F1837.HPSupportAssistant"
    "AD2F1837.HPSureShieldAI"
    "AD2F1837.HPSystemInformation"
    "AD2F1837.HPQuickDrop"
    "AD2F1837.HPWorkWell"
    "AD2F1837.myHP"
    "AD2F1837.HPDesktopSupportUtilities"
    "AD2F1837.HPQuickTouch"
    "AD2F1837.HPEasyClean"
)

$UninstallPrograms = @(
    "HP Client Security Manager"
    "HP Connection Optimizer"
    "HP Documentation"
    "HP MAC Address Manager"
    "HP Notifications"
    "HP Security Update Service"
    "HP System Default Settings"
    "HP Sure Click"
    "HP Sure Click Security Browser"
    "HP Sure Run"
    "HP Sure Recover"
    "HP Sure Sense"
    "HP Sure Sense Installer"
    "HP Wolf Security"
    "HP Wolf Security Application Support for Sure Sense"
    "HP Wolf Security Application Support for Windows"
)

$HPidentifier = "AD2F1837"
#endregion

#region Detection Logic
try {
    $BloatwareFound = $false
    $FoundItems = @()
    
    # Check for installed AppX packages
    Write-Output "Checking for HP AppX packages..."
    $InstalledPackages = Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue | 
        Where-Object {($UninstallPackages -contains $_.Name) -or ($_.Name -match "^$HPidentifier")}
    
    if ($InstalledPackages) {
        $BloatwareFound = $true
        $FoundItems += "AppX Packages: $($InstalledPackages.Count) found"
        Write-Output "Found $($InstalledPackages.Count) HP AppX package(s)"
    }
    
    # Check for provisioned packages
    Write-Output "Checking for HP provisioned packages..."
    $ProvisionedPackages = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | 
        Where-Object {($UninstallPackages -contains $_.DisplayName) -or ($_.DisplayName -match "^$HPidentifier")}
    
    if ($ProvisionedPackages) {
        $BloatwareFound = $true
        $FoundItems += "Provisioned Packages: $($ProvisionedPackages.Count) found"
        Write-Output "Found $($ProvisionedPackages.Count) HP provisioned package(s)"
    }
    
    # Check for installed programs
    Write-Output "Checking for HP installed programs..."
    $InstalledPrograms = Get-Package -ErrorAction SilentlyContinue | 
        Where-Object {$UninstallPrograms -contains $_.Name}
    
    if ($InstalledPrograms) {
        $BloatwareFound = $true
        $FoundItems += "Installed Programs: $($InstalledPrograms.Count) found"
        Write-Output "Found $($InstalledPrograms.Count) HP program(s)"
    }
    
    # Report results
    if ($BloatwareFound) {
        Write-Output "Non-Compliant: HP bloatware detected"
        Write-Output "Details: $($FoundItems -join ', ')"
        Exit 1
    }
    else {
        Write-Output "Compliant: No HP bloatware detected"
        Exit 0
    }
}
catch {
    Write-Output "Error during detection: $($_.Exception.Message)"
    Exit 1
}
#endregion