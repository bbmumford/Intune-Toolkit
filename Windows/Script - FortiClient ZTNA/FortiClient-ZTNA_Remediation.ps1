<#
.SYNOPSIS
    Registers FortiClient ZTNA with EMS using invitation code

.DESCRIPTION
    Executes FortiClient ZTNA registration by running FortiESNAC.exe with
    the --register command and the configured invitation code. Verifies
    successful registration by checking the registry value after registration.
    
    This remediation script is triggered when the detection script finds that
    the invitation code is missing or incorrect. Handles various success
    conditions including "already registered" responses.
    
.NOTES
    FileName:    FortiClient-ZTNA_Remediation.ps1
    Author:      Brandon Miller-Mumford
    Created:     2025-10-17
    Modified:    2025-10-17
    Version:     1.0
    
    Requirements:
    - PowerShell 5.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Windows 10/11
    - FortiClient ZTNA client installed
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Remediation successful (registration completed or already registered)
    - 1: Remediation failed (registration failed or FortiClient not installed)
    
    Purpose:
    - Register FortiClient ZTNA with EMS
    - Configure invitation code for Zero Trust Network Access
    - Enable secure endpoint access
    
    Change Log:
    v1.0 - Initial release (migrated from FortiZTNA scripts)
#>

#region Configuration
# ============================================================================
# CONFIGURE THIS VALUE FOR YOUR ENVIRONMENT
# ============================================================================

# FortiClient ZTNA invitation code from EMS
# Update this value with your organization's invitation code
$InvitationCode = 'CODE_HERE'

# Registry location for validation
$RegPath = 'HKLM:\SOFTWARE\Fortinet\FortiClient\FA_ESNAC'
$RegValueName = 'invitation_code'

# FortiESNAC.exe locations
$FortiESNAC_x64 = 'C:\Program Files\Fortinet\FortiClient\FortiESNAC.exe'
$FortiESNAC_x86 = 'C:\Program Files (x86)\Fortinet\FortiClient\FortiESNAC.exe'

# Wait time for registry to update after registration (seconds)
$RegistrationWaitTime = 120

#endregion Configuration

#region Helper Functions
# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Get-RegistryValueSafe {
    <#
    .SYNOPSIS
        Safely retrieves a registry value without throwing errors
    #>
    param(
        [string]$Path,
        [string]$Name
    )
    
    try {
        if (-not (Test-Path $Path)) {
            return $null
        }
        $Property = Get-ItemProperty -Path $Path -ErrorAction SilentlyContinue
        return $Property.$Name
    }
    catch {
        return $null
    }
}

#endregion Helper Functions

#region Main Remediation Logic
# ============================================================================
# MAIN REMEDIATION LOGIC
# ============================================================================

$ErrorActionPreference = 'SilentlyContinue'

Write-Output "=========================================="
Write-Output "FortiClient ZTNA Registration Remediation"
Write-Output "=========================================="
Write-Output "Start time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Output ""

try {
    # Check if already compliant
    $CurrentValue = Get-RegistryValueSafe -Path $RegPath -Name $RegValueName
    if ($CurrentValue -eq $InvitationCode) {
        Write-Output "Already compliant: Invitation code is correctly configured"
        Write-Output "Registry: $RegPath\$RegValueName = '$CurrentValue'"
        Exit 0
    }
    
    # Determine FortiESNAC.exe location
    $FortiESNAC = $null
    if (Test-Path $FortiESNAC_x64) {
        $FortiESNAC = $FortiESNAC_x64
        Write-Output "Found FortiESNAC.exe (x64): $FortiESNAC"
    }
    elseif (Test-Path $FortiESNAC_x86) {
        $FortiESNAC = $FortiESNAC_x86
        Write-Output "Found FortiESNAC.exe (x86): $FortiESNAC"
    }
    else {
        Write-Output "ERROR: FortiESNAC.exe not found"
        Write-Output "Checked locations:"
        Write-Output "  - $FortiESNAC_x64"
        Write-Output "  - $FortiESNAC_x86"
        Write-Output ""
        Write-Output "FortiClient ZTNA component may not be installed."
        Write-Output "Please install FortiClient with ZTNA support."
        Exit 1
    }
    
    # Execute registration
    Write-Output ""
    Write-Output "Executing registration command:"
    Write-Output "`"$FortiESNAC`" --register $InvitationCode"
    Write-Output ""
    
    $RegistrationOutput = & "$FortiESNAC" --register $InvitationCode 2>&1
    $RegistrationExitCode = $LASTEXITCODE
    $OutputText = ($RegistrationOutput | Out-String).Trim()
    
    Write-Output "Registration exit code: $RegistrationExitCode"
    Write-Output "Registration output:"
    Write-Output $OutputText
    Write-Output ""
    
    # Check for "already registered" response (treat as success)
    if ($OutputText -match '(?i)already\s+registered(.*EMS)?') {
        Write-Output "SUCCESS: FortiClient reports it is already registered with EMS"
        Write-Output "Treating as successful remediation."
        Exit 0
    }
    
    # Wait for registry to update
    Write-Output "Waiting $RegistrationWaitTime seconds for registration to complete..."
    Start-Sleep -Seconds $RegistrationWaitTime
    
    # Verify registration by checking registry
    $NewValue = Get-RegistryValueSafe -Path $RegPath -Name $RegValueName
    
    if ($NewValue -eq $InvitationCode) {
        Write-Output ""
        Write-Output "=========================================="
        Write-Output "SUCCESS: Registration completed"
        Write-Output "=========================================="
        Write-Output "Registry verified: $RegPath\$RegValueName"
        Write-Output "Invitation code: $NewValue"
        Exit 0
    }
    
    # Check if output indicates success
    if ($OutputText -match '(?i)(registered|registration)\s+(successful|succeeded|complete|completed)') {
        Write-Output ""
        Write-Output "SUCCESS: Registration output indicates success"
        Write-Output "Accepting based on command output."
        Exit 0
    }
    
    # Registration failed
    Write-Output ""
    Write-Output "=========================================="
    Write-Output "FAILURE: Registration did not complete"
    Write-Output "=========================================="
    
    if ($null -eq $NewValue) {
        Write-Output "Registry path or value still missing:"
        Write-Output "  Path: $RegPath"
        Write-Output "  Value: $RegValueName"
    }
    else {
        Write-Output "Invitation code mismatch:"
        Write-Output "  Expected: $InvitationCode"
        Write-Output "  Found:    $NewValue"
    }
    
    Write-Output ""
    Write-Output "Please check FortiClient logs for detailed error information."
    Exit 1
}
catch {
    Write-Output ""
    Write-Output "=========================================="
    Write-Output "ERROR: Exception during remediation"
    Write-Output "=========================================="
    Write-Output "Error message: $($_.Exception.Message)"
    Write-Output "Error details: $_"
    Exit 1
}

#endregion Main Remediation Logic
