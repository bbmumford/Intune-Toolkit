<#
.SYNOPSIS
    Removes HP pre-installed bloatware from the system

.DESCRIPTION
    Uninstalls a comprehensive list of HP bloatware applications including:
    - HP Support Assistant and related services
    - HP documentation and help software
    - HP Audio and Connection Optimizer
    - HP telemetry and analytics tools
    - Other pre-installed HP utilities
    
    Detection script checks for bloatware presence and triggers this
    remediation when needed. No completion marker required - detection
    script will verify bloatware is actually removed.
    
.NOTES
    FileName:    Uninstall-HP-Bloatware_Remediation.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-17
    Version:     2.1
    
    Requirements:
    - PowerShell 5.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - HP hardware
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Remediation successful (all bloatware removed or none found)
    - 1: Remediation failed (partial or complete failure)
    
    Purpose:
    - Remove vendor bloatware (30+ HP applications)
    - Improve system performance
    - Reduce security attack surface
    - Free up disk space
    
    Change Log:
    v2.1 - Added proper exit code handling and remediation tracking
    v2.0 - Removed unnecessary completion marker (detection checks actual state)
    v1.1 - Migrated to registry-based completion tracking
    v1.0 - Initial release
#>

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
    "AD2F1837.HPSystemInformation"
)

# List of programs to uninstall
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

# Track remediation results
$TotalBloatwareFound = 0
$SuccessfulRemovals = 0
$FailedRemovals = 0

$InstalledPackages = Get-AppxPackage -AllUsers `
            | Where-Object {($UninstallPackages -contains $_.Name) -or ($_.Name -match "^$HPidentifier")}

$ProvisionedPackages = Get-AppxProvisionedPackage -Online `
            | Where-Object {($UninstallPackages -contains $_.DisplayName) -or ($_.DisplayName -match "^$HPidentifier")}

$InstalledPrograms = Get-Package | Where-Object {$UninstallPrograms -contains $_.Name}

# Calculate total bloatware found
$TotalBloatwareFound = $InstalledPackages.Count + $ProvisionedPackages.Count + $InstalledPrograms.Count

if ($TotalBloatwareFound -eq 0) {
    Write-Host "No HP bloatware found. System is already clean."
    Exit 0
}

Write-Host "Found $TotalBloatwareFound HP bloatware item(s) to remove"

# Remove appx provisioned packages - AppxProvisionedPackage
ForEach ($ProvPackage in $ProvisionedPackages) {

    Write-Host -Object "Attempting to remove provisioned package: [$($ProvPackage.DisplayName)]..."

    Try {
        $Null = Remove-AppxProvisionedPackage -PackageName $ProvPackage.PackageName -Online -ErrorAction Stop
        Write-Host -Object "Successfully removed provisioned package: [$($ProvPackage.DisplayName)]"
        $SuccessfulRemovals++
    }
    Catch {
        Write-Warning -Message "Failed to remove provisioned package: [$($ProvPackage.DisplayName)]"
        $FailedRemovals++
    }
}

# Remove appx packages - AppxPackage
ForEach ($AppxPackage in $InstalledPackages) {
                                            
    Write-Host -Object "Attempting to remove Appx package: [$($AppxPackage.Name)]..."

    Try {
        $Null = Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction Stop
        Write-Host -Object "Successfully removed Appx package: [$($AppxPackage.Name)]"
        $SuccessfulRemovals++
    }
    Catch {
        Write-Warning -Message "Failed to remove Appx package: [$($AppxPackage.Name)]"
        $FailedRemovals++
    }
}

# Remove installed programs
$InstalledPrograms | ForEach-Object {

    Write-Host -Object "Attempting to uninstall: [$($_.Name)]..."

    Try {
        $Null = $_ | Uninstall-Package -AllVersions -Force -ErrorAction Stop
        Write-Host -Object "Successfully uninstalled: [$($_.Name)]"
        $SuccessfulRemovals++
    }
    Catch {
        Write-Warning -Message "Failed to uninstall: [$($_.Name)]"
        $FailedRemovals++
    }
}

# Fallback attempt 1 to remove HP Wolf Security using msiexec
Try {
    MsiExec /x "{0E2E04B0-9EDD-11EB-B38C-10604B96B11E}" /qn /norestart
    Write-Host -Object "Fallback to MSI uninstall for HP Wolf Security initiated"
}
Catch {
    Write-Warning -Object "Failed to uninstall HP Wolf Security using MSI - Error message: $($_.Exception.Message)"
}

# Fallback attempt 2 to remove HP Wolf Security using msiexec
Try {
    MsiExec /x "{4DA839F0-72CF-11EC-B247-3863BB3CB5A8}" /qn /norestart
    Write-Host -Object "Fallback to MSI uninstall for HP Wolf 2 Security initiated"
}
Catch {
    Write-Warning -Object  "Failed to uninstall HP Wolf Security 2 using MSI - Error message: $($_.Exception.Message)"
}

# Report results and exit with appropriate code
Write-Host ""
Write-Host "=========================================="
Write-Host "HP Bloatware Removal Summary"
Write-Host "=========================================="
Write-Host "Total items found:      $TotalBloatwareFound"
Write-Host "Successfully removed:   $SuccessfulRemovals"
Write-Host "Failed to remove:       $FailedRemovals"
Write-Host "=========================================="

if ($SuccessfulRemovals -gt 0 -and $FailedRemovals -eq 0) {
    Write-Host "SUCCESS: All HP bloatware has been removed."
    Write-Host "Detection script will verify removal on next run."
    Exit 0
}
elseif ($SuccessfulRemovals -gt 0 -and $FailedRemovals -gt 0) {
    Write-Warning "PARTIAL SUCCESS: Some bloatware was removed, but $FailedRemovals item(s) failed."
    Write-Warning "Remediation will retry on next run."
    Exit 1
}
else {
    Write-Warning "FAILURE: No bloatware was successfully removed."
    Write-Warning "Check logs for detailed error messages."
    Exit 1
}
