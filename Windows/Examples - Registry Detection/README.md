# Registry-Based Detection Examples

This directory contains example implementations of the standardized registry-based detection method.

## Files

- **Example_Detection_Template.ps1** - Template for detection scripts
- **Example_Remediation_Template.ps1** - Template for remediation scripts
- **Example_Migration_Before.ps1** - Old file-based detection method (before)
- **Example_Migration_After.ps1** - New registry-based detection method (after)

## Quick Start

### Using the Helper Module

1. **Import the module:**
```powershell
Import-Module .\IntuneScriptHelpers.psm1
```

2. **In your Detection script:**
```powershell
if (Test-IntuneScriptCompletion -ScriptName "MyScript" -SystemContext $true) {
    Write-Host "Compliant"
    exit 0
}
Write-Host "Non-Compliant"
exit 1
```

3. **In your Remediation script:**
```powershell
# Your script logic here
# ...

# Mark as complete
Set-IntuneScriptCompletion -ScriptName "MyScript" -SystemContext $true -Version "1.0"
```

## Context Selection

| Run As | Context | Registry Root | Path |
|--------|---------|---------------|------|
| System | System | `HKLM:` | `HKLM:\Software\IntuneDependencies` |
| User | User | `HKCU:` | `HKCU:\Software\IntuneDependencies` |

## See Also

- [REGISTRY_DETECTION_STANDARD.md](../REGISTRY_DETECTION_STANDARD.md) - Complete documentation
- [IntuneScriptHelpers.psm1](../IntuneScriptHelpers.psm1) - Helper functions module
