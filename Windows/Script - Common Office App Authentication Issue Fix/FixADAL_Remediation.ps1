<#
Version: 3.2
Author:
- Brandon Miller-Mumford
Script: FixADAL_Remediation.ps1
Description:
Remediates registry key settings to enforce Modern Authentication configurations.
Run as: System/User
Context: 64 Bit
#>

# Registry key paths
$registryPath = "HKCU:\Software\Microsoft\Office\16.0\Common\Identity"

# Keys to set
$keysToSet = @{
    "EnableADAL" = 0
    "DisableADALatopWAMOverride" = 1
}

# Ensure registry path exists
if (-not (Test-Path -Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Apply settings
foreach ($key in $keysToSet.GetEnumerator()) {
    try {
        Set-ItemProperty -Path $registryPath -Name $key.Key -Value $key.Value -Force
        Write-Host "Successfully set $($key.Key) to $($key.Value)." -ForegroundColor Green
    } catch {
        Write-Host "Failed to set $($key.Key): $($_.Exception.Message)" -ForegroundColor Red
    }
}