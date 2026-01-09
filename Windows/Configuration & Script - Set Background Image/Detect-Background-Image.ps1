<#
.SYNOPSIS
    Intune Remediation - Detection Script for Background Image
    
.DESCRIPTION
    Checks if the background image exists and matches the expected version.
    Exits with code 1 (Scanning for Remediation) if missing or outdated.
    Exits with code 0 (Compliant) if correct.
#>

# --- Configuration ---
# Update this version number to force a re-download on devices
$Version = "1.0" 

$LocalDirectory = "C:\ProgramData\Intune"
$LocalFileName = "background.png"
$RegPath = "HKLM:\SOFTWARE\Intune"
$RegName = "BackgroundImageVersion"
# ---------------------

$LocalFilePath = Join-Path -Path $LocalDirectory -ChildPath $LocalFileName

# 1. Check if file exists
if (-not (Test-Path -Path $LocalFilePath)) {
    Write-Output "Non-Compliant: Image file missing at $LocalFilePath"
    exit 1
}

# 2. Check version in registry
try {
    $InstalledVersion = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction Stop | Select-Object -ExpandProperty $RegName
    
    if ($InstalledVersion -ne $Version) {
        Write-Output "Non-Compliant: Version mismatch (Expected: $Version, Found: $InstalledVersion)"
        exit 1
    }
} catch {
    Write-Output "Non-Compliant: Version registry key missing"
    exit 1
}

Write-Output "Compliant: Image exists and version matches ($Version)"
exit 0
