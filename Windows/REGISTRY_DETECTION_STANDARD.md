# Registry-Based Script Completion Detection Standard

## Overview
This document defines the standardized method for tracking script execution and dependency completion using Windows Registry keys in Intune-managed environments.

## Standard Registry Paths

### System Context (Run as: System)
```
HKLM:\Software\IntuneDependencies
```
- **Use When:** Script runs as SYSTEM account
- **Scope:** Machine-wide (all users)
- **Persistence:** Survives user profile deletion
- **Access:** Requires Administrator/SYSTEM privileges

### User Context (Run as: User)
```
HKCU:\Software\IntuneDependencies
```
- **Use When:** Script runs as logged-in user
- **Scope:** Current user only
- **Persistence:** Tied to user profile
- **Access:** User-level privileges sufficient

## Naming Convention

### Value Names
Format: `{ScriptName}{Action}Completed`

**Examples:**
- `RaphireDebloatCompleted`
- `ZeroTierInstallCompleted`
- `ExplorerPatcherConfigCompleted`
- `DesktopInfoDeployCompleted`
- `TeamsNewInstallCompleted`

### Value Type
- **Type:** `DWORD` or `String`
- **Completed Value:** `1` (DWORD) or `"true"` (String) or ISO 8601 timestamp
- **Not Completed:** Value doesn't exist or is `0`/`"false"`

## Implementation Template

### Detection Script Template

```powershell
<#
.SYNOPSIS
    Detects if [ScriptName] has completed

.DESCRIPTION
    Checks registry to determine if [ScriptName] has been successfully executed.
    
.NOTES
    Registry Path: HKLM:\Software\IntuneDependencies (System context)
                   HKCU:\Software\IntuneDependencies (User context)
#>

# Configuration
$RegPath = "HKLM:\Software\IntuneDependencies"  # Change to HKCU: for user context
$RegName = "ScriptNameCompleted"
$ExpectedValue = 1  # or $true for boolean

# Detection Logic
try {
    if (Test-Path $RegPath) {
        $CurrentValue = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
        
        if ($null -ne $CurrentValue -and $CurrentValue.$RegName -eq $ExpectedValue) {
            Write-Host "Compliant: $RegName is set correctly."
            exit 0
        }
    }
    
    Write-Host "Non-Compliant: $RegName not found or incorrect value."
    exit 1
}
catch {
    Write-Host "Error checking registry: $($_.Exception.Message)"
    exit 1
}
```

### Remediation Script Template

```powershell
<#
.SYNOPSIS
    Executes [ScriptName] and marks completion

.DESCRIPTION
    Performs [action] and creates registry marker upon successful completion.
    
.NOTES
    Registry Path: HKLM:\Software\IntuneDependencies (System context)
                   HKCU:\Software\IntuneDependencies (User context)
#>

# Configuration
$RegPath = "HKLM:\Software\IntuneDependencies"  # Change to HKCU: for user context
$RegName = "ScriptNameCompleted"

try {
    # === MAIN SCRIPT LOGIC GOES HERE ===
    # Your actual script execution code
    
    
    # === MARK COMPLETION ===
    # Create registry key if it doesn't exist
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
        Write-Host "Created registry path: $RegPath"
    }
    
    # Set completion marker with timestamp
    $Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    Set-ItemProperty -Path $RegPath -Name $RegName -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $RegPath -Name "$($RegName)_Timestamp" -Value $Timestamp -Type String -Force
    
    Write-Host "Remediation successful. Marked as completed in registry."
    exit 0
}
catch {
    Write-Host "Remediation failed: $($_.Exception.Message)"
    exit 1
}
```

## Advanced: Version Tracking

For scripts that may need updates, include version tracking:

```powershell
$RegPath = "HKLM:\Software\IntuneDependencies"
$ScriptName = "MyScript"
$CurrentVersion = "2.1"

# Create registry key structure
if (-not (Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Set completion markers
Set-ItemProperty -Path $RegPath -Name "$($ScriptName)Completed" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $RegPath -Name "$($ScriptName)Version" -Value $CurrentVersion -Type String -Force
Set-ItemProperty -Path $RegPath -Name "$($ScriptName)Timestamp" -Value (Get-Date -Format "yyyy-MM-ddTHH:mm:ss") -Type String -Force
```

Detection with version check:
```powershell
$RegPath = "HKLM:\Software\IntuneDependencies"
$ScriptName = "MyScript"
$RequiredVersion = "2.1"

if (Test-Path $RegPath) {
    $Props = Get-ItemProperty -Path $RegPath -ErrorAction SilentlyContinue
    
    if ($Props."$($ScriptName)Completed" -eq 1) {
        $InstalledVersion = $Props."$($ScriptName)Version"
        
        if ($InstalledVersion -eq $RequiredVersion) {
            Write-Host "Compliant: Version $RequiredVersion installed"
            exit 0
        }
        else {
            Write-Host "Non-Compliant: Version mismatch (Installed: $InstalledVersion, Required: $RequiredVersion)"
            exit 1
        }
    }
}

Write-Host "Non-Compliant: Not installed"
exit 1
```

## Helper Functions

### Reusable Functions for Scripts

```powershell
function Test-IntuneScriptCompletion {
    <#
    .SYNOPSIS
        Tests if an Intune script has completed
    
    .PARAMETER ScriptName
        Name of the script to check
    
    .PARAMETER SystemContext
        If true, checks HKLM (System). If false, checks HKCU (User)
    
    .EXAMPLE
        Test-IntuneScriptCompletion -ScriptName "ZeroTierInstall" -SystemContext $true
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ScriptName,
        
        [Parameter(Mandatory=$false)]
        [bool]$SystemContext = $true
    )
    
    $RegRoot = if ($SystemContext) { "HKLM:" } else { "HKCU:" }
    $RegPath = "$RegRoot\Software\IntuneDependencies"
    $RegName = "$($ScriptName)Completed"
    
    try {
        if (Test-Path $RegPath) {
            $Value = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
            return ($null -ne $Value -and $Value.$RegName -eq 1)
        }
        return $false
    }
    catch {
        return $false
    }
}

function Set-IntuneScriptCompletion {
    <#
    .SYNOPSIS
        Marks an Intune script as completed in registry
    
    .PARAMETER ScriptName
        Name of the script to mark complete
    
    .PARAMETER SystemContext
        If true, writes to HKLM (System). If false, writes to HKCU (User)
    
    .PARAMETER Version
        Optional version string to track
    
    .EXAMPLE
        Set-IntuneScriptCompletion -ScriptName "ZeroTierInstall" -SystemContext $true -Version "1.0"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ScriptName,
        
        [Parameter(Mandatory=$false)]
        [bool]$SystemContext = $true,
        
        [Parameter(Mandatory=$false)]
        [string]$Version = $null
    )
    
    $RegRoot = if ($SystemContext) { "HKLM:" } else { "HKCU:" }
    $RegPath = "$RegRoot\Software\IntuneDependencies"
    
    try {
        # Create path if needed
        if (-not (Test-Path $RegPath)) {
            New-Item -Path $RegPath -Force | Out-Null
        }
        
        # Set completion marker
        Set-ItemProperty -Path $RegPath -Name "$($ScriptName)Completed" -Value 1 -Type DWord -Force
        
        # Set timestamp
        $Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        Set-ItemProperty -Path $RegPath -Name "$($ScriptName)Timestamp" -Value $Timestamp -Type String -Force
        
        # Set version if provided
        if ($Version) {
            Set-ItemProperty -Path $RegPath -Name "$($ScriptName)Version" -Value $Version -Type String -Force
        }
        
        Write-Host "Marked $ScriptName as completed in registry"
        return $true
    }
    catch {
        Write-Warning "Failed to mark completion: $($_.Exception.Message)"
        return $false
    }
}
```

## Migration Strategy

### Converting from File-Based to Registry-Based Detection

**Before (File-Based):**
```powershell
# Detection
if (Test-Path "C:\IntuneDependencies\MyScript_Detection.txt") {
    exit 0
}
exit 1

# Remediation
New-Item -Path "C:\IntuneDependencies" -ItemType Directory -Force
Set-Content -Path "C:\IntuneDependencies\MyScript_Detection.txt" -Value "Completed"
```

**After (Registry-Based):**
```powershell
# Detection
$RegPath = "HKLM:\Software\IntuneDependencies"
if ((Get-ItemProperty -Path $RegPath -Name "MyScriptCompleted" -ErrorAction SilentlyContinue).MyScriptCompleted -eq 1) {
    exit 0
}
exit 1

# Remediation
if (-not (Test-Path "HKLM:\Software\IntuneDependencies")) {
    New-Item -Path "HKLM:\Software\IntuneDependencies" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\Software\IntuneDependencies" -Name "MyScriptCompleted" -Value 1 -Type DWord -Force
```

## Best Practices

### ✅ DO

1. **Use consistent registry paths**
   - `HKLM:\Software\IntuneDependencies` for System context
   - `HKCU:\Software\IntuneDependencies` for User context

2. **Include timestamps** - Helps with troubleshooting and audit trails

3. **Use descriptive value names** - `{ScriptPurpose}Completed` format

4. **Check context before choosing path** - Match registry path to script execution context

5. **Handle errors gracefully** - Use try/catch and exit codes properly

6. **Document in script header** - Note the registry path in .NOTES section

### ❌ DON'T

1. **Don't mix contexts** - Don't write to HKLM from user context scripts

2. **Don't use random registry locations** - Stick to the standard paths

3. **Don't forget error handling** - Always wrap registry operations in try/catch

4. **Don't use complex value names** - Keep names simple and consistent

5. **Don't skip cleanup** - Consider adding removal/cleanup remediation scripts

## Quick Reference

| Context | Registry Root | Path | Example |
|---------|--------------|------|---------|
| **System** | HKLM | `HKLM:\Software\IntuneDependencies` | `Set-ItemProperty -Path "HKLM:\Software\IntuneDependencies" -Name "MyScriptCompleted" -Value 1` |
| **User** | HKCU | `HKCU:\Software\IntuneDependencies` | `Set-ItemProperty -Path "HKCU:\Software\IntuneDependencies" -Name "MyScriptCompleted" -Value 1` |

## Example: Full Implementation

### Example Detection Script
```powershell
<#
.SYNOPSIS
    Detects if ZeroTier installation is complete

.NOTES
    Registry Path: HKLM:\Software\IntuneDependencies\ZeroTierInstallCompleted
#>

$RegPath = "HKLM:\Software\IntuneDependencies"
$RegName = "ZeroTierInstallCompleted"

if (Test-Path $RegPath) {
    $Value = (Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue).$RegName
    if ($Value -eq 1) {
        Write-Host "Compliant: ZeroTier installation marked as complete"
        exit 0
    }
}

Write-Host "Non-Compliant: ZeroTier installation not complete"
exit 1
```

### Example Remediation Script
```powershell
<#
.SYNOPSIS
    Installs ZeroTier and marks completion

.NOTES
    Registry Path: HKLM:\Software\IntuneDependencies\ZeroTierInstallCompleted
#>

$RegPath = "HKLM:\Software\IntuneDependencies"
$RegName = "ZeroTierInstallCompleted"

try {
    # Install ZeroTier (example)
    Start-Process "zerotier_installer.msi" -ArgumentList "/quiet" -Wait
    
    # Mark completion
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    
    Set-ItemProperty -Path $RegPath -Name $RegName -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $RegPath -Name "$($RegName)_Timestamp" -Value (Get-Date -Format "yyyy-MM-ddTHH:mm:ss") -Type String -Force
    
    Write-Host "Installation complete and marked in registry"
    exit 0
}
catch {
    Write-Host "Installation failed: $($_.Exception.Message)"
    exit 1
}
```

## Troubleshooting

### View Current Registry Values
```powershell
# System context
Get-ItemProperty -Path "HKLM:\Software\IntuneDependencies" -ErrorAction SilentlyContinue

# User context
Get-ItemProperty -Path "HKCU:\Software\IntuneDependencies" -ErrorAction SilentlyContinue
```

### Clear Registry Values (for testing)
```powershell
# Remove specific value
Remove-ItemProperty -Path "HKLM:\Software\IntuneDependencies" -Name "ScriptNameCompleted" -ErrorAction SilentlyContinue

# Remove entire IntuneDependencies key (CAUTION!)
Remove-Item -Path "HKLM:\Software\IntuneDependencies" -Recurse -Force -ErrorAction SilentlyContinue
```

## Additional Resources

- [Microsoft Docs: Intune Proactive Remediations](https://learn.microsoft.com/en-us/mem/intune/fundamentals/remediations)
- [PowerShell Registry Provider](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_registry_provider)
- [Get-ItemProperty Documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-itemproperty)

---

**Version:** 1.0  
**Last Updated:** 2025-10-17  
**Author:** Brandon Miller-Mumford
