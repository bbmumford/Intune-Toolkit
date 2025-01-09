<#
Version: 3.2
Author:
- Brandon Miller-Mumford
Script: FixADAL_Detection.ps1
Description:
Detects specific registry key settings and confirms compliance with Modern Authentication configurations.
Run as: System/User
Context: 64 Bit
#>

# Registry key paths
$registryPath = "HKCU:\Software\Microsoft\Office\16.0\Common\Identity"

# Detection logic
$keysToDetect = @{
    "EnableADAL" = 0
    "DisableADALatopWAMOverride" = 1
}

# Loop through and check compliance
foreach ($key in $keysToDetect.GetEnumerator()) {
    $keyPath = "$registryPath\$($key.Key)"
    $currentValue = (Get-ItemProperty -Path $registryPath -Name $key.Key -ErrorAction SilentlyContinue).$($key.Key)
    
    if ($currentValue -ne $key.Value) {
        Write-Host "Non-compliance detected: $($key.Key) is set to $currentValue but should be $($key.Value)." -ForegroundColor Red
    } else {
        Write-Host "Compliance confirmed: $($key.Key) is set correctly." -ForegroundColor Green
    }
}