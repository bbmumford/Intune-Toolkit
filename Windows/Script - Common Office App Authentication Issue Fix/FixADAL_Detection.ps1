<#
.SYNOPSIS
    Detects if Office Modern Authentication (ADAL) settings are configured

.DESCRIPTION
    Checks if Microsoft Office applications are configured to use Modern Authentication
    instead of legacy Basic Authentication. Detects specific registry settings required
    for OAuth 2.0 and Modern Authentication compliance.
    
    Validates registry keys for:
    - Office 2016/2019/365 Modern Authentication settings
    - ADAL (Azure Active Directory Authentication Library) configuration
    
.NOTES
    FileName:    FixADAL_Detection.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     3.2
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System/User
    - Context: 64 Bit
    - Microsoft Office 2016/2019/365
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (Modern Authentication configured)
    - 1: Non-Compliant (triggers remediation)
    
    Purpose:
    - Enables Modern Authentication for Office apps
    - Resolves authentication failures with Microsoft 365
    - Required for Conditional Access policies
    - Improves security with MFA support
    
    Change Log:
    v3.2 - Current version
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