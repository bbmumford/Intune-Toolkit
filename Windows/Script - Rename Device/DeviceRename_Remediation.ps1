<#
.SYNOPSIS
    Renames Windows device to match organizational naming standard

.DESCRIPTION
    Renames the Windows device to the format: {OrgShort}-{SerialNumber}
    Uses a 4-tier fallback for serial number detection:
    1. BIOS Serial Number
    2. System UUID
    3. MAC Address
    4. Random 8-character alphanumeric with UN prefix (Unknown)
    
    Device names are automatically truncated to 15 characters to comply with NetBIOS limits.
    Fully automated with no user prompts. Device restart required after successful rename.
    
.NOTES
    FileName:    DeviceRename_Remediation.ps1
    Author:      
    Created:     
    Modified:    2025-10-16
    Version:     1.1
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Remediation successful (device renamed)
    - 1: Remediation failed (error occurred)
    
    Configuration:
    - Set $OrgShort variable to your organization prefix before deployment
    
    Important:
    - Device restart required after successful rename
    - No user prompts - fully automated operation
    
    Change Log:
    v1.1 - Added 4-tier fallback system, removed user prompts, automatic truncation
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
# REMEDIATION LOGIC - DO NOT MODIFY BELOW
# ============================================

try {
    Write-Output "=== Device Rename Remediation Started ==="
    
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
    
    # Construct new name
    $prefix = $OrgShort -replace '[^a-zA-Z0-9-]', ''
    $newName = "$prefix-$serial"
    $newName = $newName.Trim('-')
    
    # Truncate if necessary (same logic as detection script)
    if ($newName.Length -gt $MaxNameLength) {
        Write-Output "WARNING: Proposed name exceeds $MaxNameLength characters. Truncating..."
        
        $serialLength = $serial.Length
        $prefixMaxLength = $MaxNameLength - $serialLength - 1
        
        if ($prefixMaxLength -gt 0) {
            $truncatedPrefix = $prefix.Substring(0, [Math]::Min($prefixMaxLength, $prefix.Length))
            $newName = "$truncatedPrefix-$serial"
        }
        
        if ($newName.Length -gt $MaxNameLength) {
            $newName = $newName.Substring(0, $MaxNameLength)
        }
        
        $newName = $newName.TrimEnd('-')
    }
    
    $newName = $newName.ToUpper()
    
    # Validate new name
    if ([string]::IsNullOrWhiteSpace($newName)) {
        Write-Output "ERROR: Generated computer name is empty"
        exit 1
    }
    
    Write-Output "New computer name will be: $newName"
    
    # Check if already correct (shouldn't happen if detection worked properly)
    if ($currentName.ToUpper() -eq $newName) {
        Write-Output "INFO: Computer name is already correct"
        exit 0
    }
    
    # Perform the rename
    Write-Output "Renaming computer from '$currentName' to '$newName'..."
    
    try {
        Rename-Computer -NewName $newName -Force -ErrorAction Stop
        Write-Output "SUCCESS: Computer renamed to $newName"
        Write-Output "INFO: A restart is required for the name change to take effect"
        Write-Output "INFO: Intune will automatically restart the device if configured"
        exit 0
    }
    catch {
        Write-Output "ERROR: Failed to rename computer - $($_.Exception.Message)"
        
        # Try alternative method using WMI
        Write-Output "Attempting alternative rename method..."
        try {
            $computer = Get-CimInstance -ClassName Win32_ComputerSystem
            $computer | Invoke-CimMethod -MethodName Rename -Arguments @{Name = $newName}
            Write-Output "SUCCESS: Computer renamed using WMI method"
            Write-Output "INFO: A restart is required for the name change to take effect"
            exit 0
        }
        catch {
            Write-Output "ERROR: Alternative rename method also failed - $($_.Exception.Message)"
            exit 1
        }
    }
}
catch {
    Write-Output "ERROR: Remediation failed - $($_.Exception.Message)"
    Write-Output "Stack trace: $($_.ScriptStackTrace)"
    exit 1
}
