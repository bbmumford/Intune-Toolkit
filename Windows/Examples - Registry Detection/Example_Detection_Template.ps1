<#
.SYNOPSIS
    Template for Detection scripts using registry-based completion tracking

.DESCRIPTION
    Detects if a script has been successfully executed by checking for a
    registry marker in the standardized IntuneDependencies location.
    
    This template follows the standardized registry detection method.

.NOTES
    FileName:    Example_Detection_Template.ps1
    Author:      Brandon Miller-Mumford
    Created:     2025-10-17
    Version:     1.0
    
    Requirements:
    - PowerShell 5.0+
    - Run as: System or User (match with remediation context)
    - Context: 64 Bit
    - Windows 10/11
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (script execution completed)
    - 1: Non-Compliant (script needs to run)
    
    Registry Path:
    - System Context: HKLM:\Software\IntuneDependencies
    - User Context:   HKCU:\Software\IntuneDependencies
    
    Change Log:
    v1.0 - Initial template
#>

#region Configuration
# ============================================================================
# CUSTOMIZE THESE VALUES FOR YOUR SCRIPT
# ============================================================================

# Script name (without "Completed" suffix)
$ScriptName = "MyScriptName"  # Example: "ZeroTierInstall", "DesktopInfo", etc.

# Context: $true for System (HKLM), $false for User (HKCU)
$SystemContext = $true

# Optional: Require specific version
$RequiredVersion = $null  # Example: "1.0" or leave as $null

#endregion Configuration

#region Detection Logic
# ============================================================================
# STANDARD DETECTION LOGIC - TYPICALLY NO CHANGES NEEDED BELOW THIS LINE
# ============================================================================

try {
    # Determine registry path based on context
    $RegRoot = if ($SystemContext) { "HKLM:" } else { "HKCU:" }
    $RegPath = "$RegRoot\Software\IntuneDependencies"
    $RegName = "$($ScriptName)Completed"
    
    # Check if registry path exists
    if (-not (Test-Path $RegPath)) {
        Write-Host "Non-Compliant: Registry path does not exist"
        exit 1
    }
    
    # Get completion marker
    $CompletionValue = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
    
    if ($null -eq $CompletionValue) {
        Write-Host "Non-Compliant: Completion marker not found"
        exit 1
    }
    
    # Check if marked as completed
    $IsCompleted = ($CompletionValue.$RegName -eq 1) -or 
                   ($CompletionValue.$RegName -eq $true) -or 
                   ($CompletionValue.$RegName -eq "true")
    
    if (-not $IsCompleted) {
        Write-Host "Non-Compliant: Not marked as completed"
        exit 1
    }
    
    # Optional: Version check
    if ($RequiredVersion) {
        $VersionValue = Get-ItemProperty -Path $RegPath -Name "$($ScriptName)Version" -ErrorAction SilentlyContinue
        $InstalledVersion = $VersionValue."$($ScriptName)Version"
        
        if ($InstalledVersion -ne $RequiredVersion) {
            Write-Host "Non-Compliant: Version mismatch (Required: $RequiredVersion, Found: $InstalledVersion)"
            exit 1
        }
        
        Write-Host "Compliant: Script completed with correct version ($RequiredVersion)"
    }
    else {
        Write-Host "Compliant: Script execution completed"
    }
    
    exit 0
}
catch {
    Write-Host "Error during detection: $($_.Exception.Message)"
    exit 1
}

#endregion Detection Logic
