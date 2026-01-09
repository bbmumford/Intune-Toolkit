<#
.SYNOPSIS
    Template for Remediation scripts using registry-based completion tracking

.DESCRIPTION
    Executes script logic and marks completion in the standardized 
    Intune registry location.
    
    This template follows the standardized registry detection method.

.NOTES
    FileName:    Example_Remediation_Template.ps1
    Author:      Brandon Miller-Mumford
    Created:     2025-10-17
    Version:     1.0
    
    Requirements:
    - PowerShell 5.0+
    - Run as: System or User (match with detection context)
    - Context: 64 Bit
    - Windows 10/11
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Remediation successful
    - 1: Remediation failed
    
    Registry Path:
    - System Context: HKLM:\Software\Intune
    - User Context:   HKCU:\Software\Intune
    
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

# Optional: Version tracking
$ScriptVersion = "1.0"

#endregion Configuration

#region Main Script Logic
# ============================================================================
# YOUR CUSTOM SCRIPT LOGIC GOES HERE
# ============================================================================

try {
    Write-Host "Starting remediation for $ScriptName..."
    
    # -----------------------------------------------------------------------
    # INSERT YOUR SCRIPT LOGIC HERE
    # -----------------------------------------------------------------------
    
    # Example: Install something
    # Start-Process "installer.msi" -ArgumentList "/quiet" -Wait
    
    # Example: Configure something
    # Set-ItemProperty -Path "HKLM:\Some\Path" -Name "Setting" -Value "Value"
    
    # Example: Download and run something
    # Invoke-WebRequest -Uri "https://example.com/file.exe" -OutFile "$env:TEMP\file.exe"
    # Start-Process "$env:TEMP\file.exe" -ArgumentList "/silent" -Wait
    
    Write-Host "Script logic completed successfully"
    
    # -----------------------------------------------------------------------
    # END OF YOUR CUSTOM LOGIC
    # -----------------------------------------------------------------------
    
}
catch {
    Write-Host "Script logic failed: $($_.Exception.Message)"
    exit 1
}

#endregion Main Script Logic

#region Mark Completion
# ============================================================================
# STANDARD COMPLETION MARKING - TYPICALLY NO CHANGES NEEDED BELOW THIS LINE
# ============================================================================

try {
    # Determine registry path based on context
    $RegRoot = if ($SystemContext) { "HKLM:" } else { "HKCU:" }
    $RegPath = "$RegRoot\Software\Intune"
    
    # Create registry path if it doesn't exist
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
        Write-Host "Created registry path: $RegPath"
    }
    
    # Set completion marker
    $RegName = "$($ScriptName)Completed"
    Set-ItemProperty -Path $RegPath -Name $RegName -Value 1 -Type DWord -Force
    Write-Host "Marked as completed: $RegName"
    
    # Set timestamp
    $Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    Set-ItemProperty -Path $RegPath -Name "$($ScriptName)Timestamp" -Value $Timestamp -Type String -Force
    Write-Host "Set timestamp: $Timestamp"
    
    # Optional: Set version
    if ($ScriptVersion) {
        Set-ItemProperty -Path $RegPath -Name "$($ScriptName)Version" -Value $ScriptVersion -Type String -Force
        Write-Host "Set version: $ScriptVersion"
    }
    
    Write-Host "Successfully marked '$ScriptName' as completed in registry"
    Write-Host "Registry Path: $RegPath"
    exit 0
}
catch {
    Write-Host "Failed to mark completion: $($_.Exception.Message)"
    Write-Host "Script executed successfully but completion marker failed"
    exit 1
}

#endregion Mark Completion
