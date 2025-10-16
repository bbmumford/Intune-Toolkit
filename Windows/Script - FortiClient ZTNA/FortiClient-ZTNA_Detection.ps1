<#
.SYNOPSIS
    Detects if FortiClient ZTNA is properly registered with EMS

.DESCRIPTION
    Checks the FortiClient ESNAC registry key to verify that the invitation
    code is correctly configured. This detection script is part of an Intune
    Proactive Remediation to ensure FortiClient ZTNA (Zero Trust Network Access)
    clients are properly registered with the EMS (Enterprise Management Server).
    
    If the invitation code is missing or incorrect, triggers the remediation
    script to register the client.
    
.NOTES
    FileName:    FortiClient-ZTNA_Detection.ps1
    Author:      Brandon Miller-Mumford
    Created:     2025-10-17
    Modified:    2025-10-17
    Version:     1.0
    
    Requirements:
    - PowerShell 5.0+
    - Run as: System
    - Context: 64 Bit
    - Windows 10/11
    - FortiClient ZTNA client installed
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (invitation code matches expected value)
    - 1: Non-Compliant (triggers remediation)
    
    Registry Path:
    HKLM:\SOFTWARE\Fortinet\FortiClient\FA_ESNAC
    
    Registry Value:
    invitation_code (String)
    
    Purpose:
    - Ensure FortiClient ZTNA is registered with EMS
    - Verify correct invitation code is configured
    - Enable Zero Trust Network Access for endpoints
    
    Change Log:
    v1.0 - Initial release (migrated from FortiZTNA scripts)
#>

#region Configuration
# ============================================================================
# CONFIGURE THIS VALUE FOR YOUR ENVIRONMENT
# ============================================================================

# Expected FortiClient ZTNA invitation code
# Update this value with your organization's invitation code from EMS
$InvitationCode = 'CODE_HERE'

# Registry location (typically does not need to be changed)
$RegPath = 'HKLM:\SOFTWARE\Fortinet\FortiClient\FA_ESNAC'
$RegValueName = 'invitation_code'

#endregion Configuration

#region Detection Logic
# ============================================================================
# DETECTION LOGIC - NO CHANGES NEEDED BELOW THIS LINE
# ============================================================================

$ErrorActionPreference = 'SilentlyContinue'

try {
    # Check if registry path exists
    if (-not (Test-Path $RegPath)) {
        Write-Output "Non-Compliant: FortiClient ESNAC registry path not found: $RegPath"
        Write-Output "FortiClient may not be installed or ZTNA component is missing."
        Exit 1
    }
    
    # Get the invitation code value
    $CurrentValue = (Get-ItemProperty -Path $RegPath -Name $RegValueName -ErrorAction SilentlyContinue).$RegValueName
    
    # Check if value exists
    if ($null -eq $CurrentValue) {
        Write-Output "Non-Compliant: Invitation code registry value not found: $RegValueName"
        Write-Output "FortiClient ZTNA registration has not been completed."
        Exit 1
    }
    
    # Check if value matches expected
    if ($CurrentValue -ne $InvitationCode) {
        Write-Output "Non-Compliant: Invitation code mismatch"
        Write-Output "Current:  '$CurrentValue'"
        Write-Output "Expected: '$InvitationCode'"
        Exit 1
    }
    
    # All checks passed
    Write-Output "Compliant: FortiClient ZTNA is properly registered"
    Write-Output "Invitation code matches expected value"
    Exit 0
}
catch {
    Write-Output "Error during detection: $($_.Exception.Message)"
    Exit 1
}

#endregion Detection Logic
