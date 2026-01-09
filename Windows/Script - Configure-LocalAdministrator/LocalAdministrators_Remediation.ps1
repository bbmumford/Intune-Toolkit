<#
.SYNOPSIS
    Renames and enables the default local Administrator account

.DESCRIPTION
    Remediates the default local Administrator account (SID *-500) by:
    - Renaming it to the specified name
    - Enabling the account if disabled
    - Ensuring membership in the Administrators group
    - Removing any duplicate accounts with the same name
    
    Uses ADSI (Active Directory Service Interfaces) for compatibility with:
    - Windows 7/8/10/11 and Server 2008 R2+
    - All PowerShell versions (2.0+)
    
    Compatible alternative to Rename-LocalUser/Enable-LocalUser cmdlets which
    require PowerShell 5.1+ and are not available on older Windows versions.
    
.NOTES
    FileName:    LocalAdministrators_Remediation.ps1
    Author:      
    Created:     
    Modified:    2025-10-16
    Version:     1.1
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Windows 7/8/10/11 and Server 2008 R2+
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Remediation successful
    - 1: Remediation failed
    
    Configuration:
    - Set $NewAdminName variable before deployment
    
    Features:
    - Duplicate account detection and removal
    - Automatic group membership verification
    - Comprehensive error handling and logging
    
    Change Log:
    v1.1 - Replaced cmdlets with ADSI for universal compatibility, added duplicate handling
    v1.0 - Initial release
#>

# Define the expected administrator account name
$NewAdminName = "Company.LocalAdmin"

function Get-LocalAccounts {
    if (Get-Command -Name Get-CimInstance -ErrorAction SilentlyContinue) {
        try {
            return Get-CimInstance -ClassName Win32_UserAccount -Filter "LocalAccount=True" -ErrorAction Stop
        }
        catch {}
    }

    return Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount=True" -ErrorAction Stop
}

try {
    Write-Output "=== Local Administrator Remediation Started ==="

    $AllAccounts = Get-LocalAccounts

    # Find the default Administrator account (SID ending in -500)
    $AdminAccount = $AllAccounts | Where-Object { $_.SID -like "S-1-5-*-500" }

    if (-not $AdminAccount) {
        Write-Output "ERROR: Default Administrator account (SID *-500) not found."
        exit 1
    }

    Write-Output "Found default Administrator account: $($AdminAccount.Name) (SID: $($AdminAccount.SID))"

    # Find any duplicate accounts with the target name (not the default admin)
    $DuplicateAccounts = $AllAccounts | Where-Object {
        $_.Name -eq $NewAdminName -and $_.SID -ne $AdminAccount.SID
    }

    # Remove duplicate accounts using the computer container
    if ($DuplicateAccounts) {
        Write-Output "Found duplicate account(s) with name '$NewAdminName'. Removing..."
        $Computer = [ADSI]"WinNT://./"

        foreach ($Duplicate in $DuplicateAccounts) {
            try {
                $Computer.Delete("user", $Duplicate.Name)
                Write-Output "Removed duplicate account: $($Duplicate.Name) (SID: $($Duplicate.SID))"
            }
            catch {
                Write-Output "WARNING: Failed to remove duplicate account '$($Duplicate.Name)': $_"
            }
        }
    }

    # Check if default admin already has the correct name
    if ($AdminAccount.Name -eq $NewAdminName) {
        Write-Output "Administrator account already has correct name: $NewAdminName"
    }
    else {
        Write-Output "Renaming '$($AdminAccount.Name)' to '$NewAdminName'..."
        try {
            $user = [ADSI]"WinNT://./$($AdminAccount.Name),user"
            $user.Rename($NewAdminName)
            Write-Output "Successfully renamed to '$NewAdminName'"
        }
        catch {
            Write-Output "ERROR: Failed to rename administrator account: $_"
            exit 1
        }

        # Refresh account data after rename
        $AllAccounts = Get-LocalAccounts
        $AdminAccount = $AllAccounts | Where-Object { $_.SID -like "S-1-5-*-500" }
    }

    # Enable the account if disabled
    try {
        $user = [ADSI]"WinNT://./$NewAdminName,user"
        $isDisabled = ($user.UserFlags.Value -band 0x2) -ne 0

        if ($isDisabled) {
            Write-Output "Enabling administrator account..."
            $user.UserFlags = $user.UserFlags.Value -band (-bnot 0x2) # Remove disabled flag
            $user.SetInfo()
            Write-Output "Administrator account enabled"
        }
        else {
            Write-Output "Administrator account is already enabled"
        }
    }
    catch {
        Write-Output "ERROR: Failed to enable administrator account: $_"
        exit 1
    }

    # Ensure account is in Administrators group
    Write-Output "Verifying Administrators group membership..."
    try {
        $AdminsGroup = [ADSI]"WinNT://./Administrators,group"
        $Members = @($AdminsGroup.Invoke("Members")) | ForEach-Object {
            $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
        }

        if ($Members -notcontains $NewAdminName) {
            Write-Output "Adding '$NewAdminName' to Administrators group..."
            $AdminsGroup.Add("WinNT://./$NewAdminName,user")
            Write-Output "Added to Administrators group"
        }
        else {
            Write-Output "Account is already in Administrators group"
        }
    }
    catch {
        Write-Output "WARNING: Could not verify Administrators group membership: $_"
    }

    Write-Output "=== Remediation Completed Successfully ==="
    Write-Output "Administrator account '$NewAdminName' is configured and enabled"
    exit 0
}
catch {
    Write-Output "ERROR: Remediation failed - $($_.Exception.Message)"
    Write-Output "Stack trace: $($_.ScriptStackTrace)"
    exit 1
}
