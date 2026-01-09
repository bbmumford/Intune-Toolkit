<#
.SYNOPSIS
    Detects if local Administrator account is properly renamed and enabled

.DESCRIPTION
    Checks if the default local Administrator account (SID *-500) is:
    - Renamed to the expected name
    - Currently enabled
    - Member of the Administrators group
    
    Uses WMI/CIM for compatibility with Windows 7/8/10/11 and all PowerShell versions.
    Compatible alternative to Get-LocalUser cmdlet which requires PowerShell 5.1+.
    
.NOTES
    FileName:    LocalAdministrators_Detection.ps1
    Author:      
    Created:     
    Modified:    2025-10-16
    Version:     1.1
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System
    - Context: 64 Bit
    - Windows 7/8/10/11 and Server 2008 R2+
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (account properly configured)
    - 1: Non-Compliant (triggers remediation)
    
    Configuration:
    - Set $ExpectedAdminName variable before deployment
    
    Change Log:
    v1.1 - Replaced Get-LocalUser with WMI/CIM for universal compatibility
    v1.0 - Initial release
#>

# Define the expected administrator account name
$ExpectedAdminName = "Company.LocalAdmin"

function Get-LocalAccounts {
    # Prefer CIM when available, fall back to WMI for PowerShell 2.0/older hosts
    if (Get-Command -Name Get-CimInstance -ErrorAction SilentlyContinue) {
        try {
            return Get-CimInstance -ClassName Win32_UserAccount -Filter "LocalAccount=True" -ErrorAction Stop
        }
        catch {}
    }

    return Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount=True" -ErrorAction Stop
}

function Get-AdministratorsMembers {
    # ADSI is the most reliable way to inspect the local Administrators group
    try {
        $admins = [ADSI]"WinNT://./Administrators,group"
        return @($admins.Invoke("Members")) | ForEach-Object {
            $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
        }
    }
    catch {
        return @()
    }
}

try {
    $AllAccounts = Get-LocalAccounts

    # Find the default Administrator account (SID ending in -500)
    $AdminAccount = $AllAccounts | Where-Object { $_.SID -like "S-1-5-*-500" }

    # Find the expected admin account (in case it already exists as separate account)
    $ExpectedAccount = $AllAccounts | Where-Object { $_.Name -eq $ExpectedAdminName }

    # Check if default Administrator account exists
    if (-not $AdminAccount) {
        Write-Output "Non-Compliant: Default Administrator account (SID *-500) not found."
        exit 1
    }

    # Check if the default admin is properly renamed and enabled
    if ($AdminAccount.Name -eq $ExpectedAdminName -and -not $AdminAccount.Disabled) {
        $AdminMembers = Get-AdministratorsMembers

        if ($AdminMembers -contains $ExpectedAdminName) {
            Write-Output "Compliant: Administrator account '$ExpectedAdminName' is properly configured and is an administrator."
            exit 0
        }
        else {
            Write-Output "Non-Compliant: Account '$ExpectedAdminName' exists but is not in Administrators group."
            exit 1
        }
    }
    # Check if a different account with expected name exists (duplicate scenario)
    elseif ($ExpectedAccount -and $ExpectedAccount.SID -ne $AdminAccount.SID) {
        Write-Output "Non-Compliant: Duplicate account '$ExpectedAdminName' exists (not the default admin). Default admin is '$($AdminAccount.Name)'."
        exit 1
    }
    # Default admin not properly configured
    else {
        $status = if ($AdminAccount.Disabled) { "disabled" } else { "enabled" }
        Write-Output "Non-Compliant: Default Administrator account is named '$($AdminAccount.Name)' ($status), expected '$ExpectedAdminName' (enabled)."
        exit 1
    }
}
catch {
    Write-Output "ERROR: Failed to check administrator account configuration - $($_.Exception.Message)"
    exit 1
}
