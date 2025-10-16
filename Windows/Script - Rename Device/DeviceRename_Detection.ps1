<#
.SYNOPSIS
    Detects if Windows device name matches organizational naming standard

.DESCRIPTION
    Checks if the Windows device name matches the expected format: {OrgShort}-{SerialNumber}
    Uses a 4-tier fallback for serial number detection:
    1. BIOS Serial Number
    2. System UUID
    3. MAC Address
    4. Random 8-character alphanumeric with UN prefix (Unknown)
    
    Device names are automatically truncated to 15 characters to comply with NetBIOS limits.
    
.NOTES
    FileName:    DeviceRename_Detection.ps1
    Author:      
    Created:     
    Modified:    2025-10-16
    Version:     1.1
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System
    - Context: 64 Bit
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (device name matches expected format)
    - 1: Non-Compliant (triggers remediation)
    
    Configuration:
    - Set $OrgShort variable to your organization prefix before deployment
    
    Change Log:
    v1.1 - Added 4-tier fallback system for serial detection
    v1.0 - Initial release
#>

# ============================================
# CONFIGURATION - CUSTOMIZE BEFORE DEPLOYMENT
# ============================================

# Organization prefix (customize this for your organization)
$OrgShort = "ORG"  # Change to your organization short name (e.g., "ACME", "CONTOSO")

# Maximum computer name length
$MaxNameLength = 15

# ============================================
# DETECTION LOGIC - DO NOT MODIFY BELOW
# ============================================

try {
    # Get current computer name
    $currentName = $env:COMPUTERNAME
    Write-Output "Current computer name: $currentName"
    
    # Get device serial number with fallback methods
    $serial = (Get-CimInstance -ClassName Win32_BIOS -ErrorAction Stop).SerialNumber
    
    # Clean serial number - remove invalid characters
    if (-not [string]::IsNullOrWhiteSpace($serial)) {
        $serial = $serial -replace '[^a-zA-Z0-9-]', ''
    }
    
    # If serial is empty or invalid, try fallback methods
    if ([string]::IsNullOrWhiteSpace($serial)) {
        Write-Output "WARNING: BIOS serial number is empty, trying fallback methods..."
        
        # Fallback 1: Try UUID
        $uuid = (Get-CimInstance -ClassName Win32_ComputerSystemProduct -ErrorAction SilentlyContinue).UUID
        if (-not [string]::IsNullOrWhiteSpace($uuid)) {
            $serial = ($uuid -replace '-', '').Substring([Math]::Max(0, $uuid.Length - 12))
            Write-Output "Using UUID-based identifier: $serial"
        }
        # Fallback 2: MAC Address
        elseif ($null -eq $serial -or $serial -eq '') {
            $mac = (Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -ErrorAction SilentlyContinue | 
                    Where-Object { $_.IPEnabled -eq $true } | 
                    Select-Object -First 1).MACAddress
            if (-not [string]::IsNullOrWhiteSpace($mac)) {
                $serial = $mac -replace ':', '' -replace '-', ''
                Write-Output "Using MAC address-based identifier: $serial"
            }
        }
        # Fallback 3: Generated random identifier with UN prefix (Unknown)
        if ([string]::IsNullOrWhiteSpace($serial)) {
            Write-Output "WARNING: All hardware identifiers unavailable, generating random identifier"
            # Generate 8-character random alphanumeric string
            $random = -join ((48..57) + (65..90) | Get-Random -Count 8 | ForEach-Object {[char]$_})
            $serial = "UN$random"
            Write-Output "Using generated identifier: $serial (UN = Unknown device)"
        }
    }
    
    if ([string]::IsNullOrWhiteSpace($serial)) {
        Write-Output "ERROR: Unable to retrieve or generate device identifier"
        exit 1
    }
    
    Write-Output "Device identifier: $serial"
    
    # Construct expected name
    $expectedPrefix = $OrgShort -replace '[^a-zA-Z0-9-]', ''
    $expectedName = "$expectedPrefix-$serial"
    $expectedName = $expectedName.Trim('-')
    
    # Truncate if necessary (same logic as rename script)
    if ($expectedName.Length -gt $MaxNameLength) {
        $serialLength = $serial.Length
        $prefixMaxLength = $MaxNameLength - $serialLength - 1
        
        if ($prefixMaxLength -gt 0) {
            $truncatedPrefix = $expectedPrefix.Substring(0, [Math]::Min($prefixMaxLength, $expectedPrefix.Length))
            $expectedName = "$truncatedPrefix-$serial"
        }
        
        if ($expectedName.Length -gt $MaxNameLength) {
            $expectedName = $expectedName.Substring(0, $MaxNameLength)
        }
        
        $expectedName = $expectedName.TrimEnd('-')
    }
    
    $expectedName = $expectedName.ToUpper()
    Write-Output "Expected computer name: $expectedName"
    
    # Compare names (case-insensitive)
    if ($currentName.ToUpper() -eq $expectedName) {
        Write-Output "COMPLIANT: Device name matches expected format"
        Write-Output "Device is correctly named as: $currentName"
        exit 0  # Compliant - no remediation needed
    }
    else {
        Write-Output "NON-COMPLIANT: Device name does not match expected format"
        Write-Output "Current: $currentName"
        Write-Output "Expected: $expectedName"
        exit 1  # Non-compliant - trigger remediation
    }
}
catch {
    Write-Output "ERROR: Detection failed - $($_.Exception.Message)"
    # Exit 1 to trigger remediation in case of errors
    exit 1
}
