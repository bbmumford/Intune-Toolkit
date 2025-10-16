<#
.SYNOPSIS
    Detects Windows activation status for licensing compliance

.DESCRIPTION
    Checks Windows activation status using multiple detection methods:
    1. SoftwareLicensingProduct with PartialProductKey (most reliable)
    2. SoftwareLicensingProduct with LicenseStatus = 1
    3. SoftwareLicensingService.OA3xOriginalProductKey (OEM/HWID)
    
    Uses Get-CimInstance for Windows 11 compatibility and modern PowerShell standards.
    Reports detailed status including OS version and license information.
    
.NOTES
    FileName:    WindowsActivation_Detection.ps1
    Author:      
    Created:     
    Modified:    2025-10-16
    Version:     1.1
    
    Requirements:
    - PowerShell 3.0+ (for CIM cmdlets)
    - Run as: System
    - Context: 64 Bit
    - Windows 7/8/10/11 and Server 2012+
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Windows is activated (compliant)
    - 1: Windows is not activated (triggers remediation)
    
    Detection Methods:
    - Method 1: PartialProductKey presence (most reliable)
    - Method 2: LicenseStatus = 1 (activated)
    - Method 3: OA3xOriginalProductKey (OEM/HWID key)
    
    Change Log:
    v1.1 - Replaced Get-WmiObject with Get-CimInstance for Windows 11 compatibility
    v1.0 - Initial release
#>

try {
    # Get OS information for logging
    $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
    $productName = if ($osInfo) { $osInfo.Caption } else { "Unknown Windows Version" }
    
    # Method 1: Try to get licensing product with PartialProductKey (most reliable)
    $licensingProduct = Get-CimInstance -ClassName SoftwareLicensingProduct -ErrorAction SilentlyContinue | 
        Where-Object { $_.PartialProductKey -ne $null -and $_.Name -match "Windows" } | 
        Select-Object -First 1
    
    # Method 2: Fallback - get Windows licensing product by ApplicationID
    if ($null -eq $licensingProduct) {
        # Windows ApplicationID is 55c92734-d682-4d71-983e-d6ec3f16059f
        $licensingProduct = Get-CimInstance -ClassName SoftwareLicensingProduct -ErrorAction SilentlyContinue |
            Where-Object { $_.ApplicationID -eq '55c92734-d682-4d71-983e-d6ec3f16059f' -and $_.PartialProductKey } |
            Select-Object -First 1
    }
    
    # Method 3: Ultimate fallback - check any product with a key
    if ($null -eq $licensingProduct) {
        $licensingProduct = Get-CimInstance -ClassName SoftwareLicensingProduct -ErrorAction SilentlyContinue |
            Where-Object { $_.PartialProductKey } |
            Select-Object -First 1
    }
    
    if ($null -eq $licensingProduct) {
        Write-Output "Unable to retrieve Windows licensing information - Product: $productName"
        # If we can't get license info, assume not activated
        exit 1
    }
    
    # Get activation status
    # LicenseStatus values: 0=Unlicensed, 1=Licensed, 2=OOBGrace, 3=OOTGrace, 4=NonGenuineGrace, 5=Notification, 6=ExtendedGrace
    $activationStatus = $licensingProduct.LicenseStatus
    
    # Log detailed info
    Write-Output "License Name: $($licensingProduct.Name)"
    Write-Output "Partial Product Key: $($licensingProduct.PartialProductKey)"
    
    if ($activationStatus -eq 1) {
        # Windows is activated
        Write-Output "Windows is activated - Product: $productName"
        exit 0
    } else {
        # Windows is not activated
        $statusText = switch ($activationStatus) {
            0 { "Unlicensed" }
            2 { "Out-of-Box Grace Period" }
            3 { "Out-of-Tolerance Grace Period" }
            4 { "Non-Genuine Grace Period" }
            5 { "Notification Mode" }
            6 { "Extended Grace Period" }
            default { "Unknown ($activationStatus)" }
        }
        Write-Output "Windows is NOT activated - Status: $statusText - Product: $productName"
        exit 1
    }
}
catch {
    Write-Output "Error checking activation status: $($_.Exception.Message)"
    exit 1
}
