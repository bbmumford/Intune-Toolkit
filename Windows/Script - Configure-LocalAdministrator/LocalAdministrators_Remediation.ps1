# Define the expected administrator account name
$NewAdminName = "Company.LocalAdmin"

# Find all local accounts
$AllAccounts = Get-LocalUser

# Find the default Administrator account (SID ending in -500)
$AdminAccount = $AllAccounts | Where-Object { $_.SID -like "S-1-5-*-500" }

# Find other accounts with the same name as the expected administrator
$DuplicateAccounts = $AllAccounts | Where-Object { $_.Name -eq $NewAdminName -and $_.SID -ne $AdminAccount.SID }

# Remove duplicate accounts with the same name as the expected administrator
try {
    if ($DuplicateAccounts) {
        foreach ($DuplicateAccount in $DuplicateAccounts) {
            Remove-LocalUser -Name $DuplicateAccount.Name
            Write-Output "Duplicate account '$($DuplicateAccount.Name)' removed."
        }
    }
} catch {
    Write-Error "Failed to remove duplicate account(s): $_"
    exit 1 # Exit with failure code if unable to remove duplicates
}

# Rename and enable the default Administrator account
try {
    if ($AdminAccount) {
        Rename-LocalUser -Name $AdminAccount.Name -NewName $NewAdminName
        Enable-LocalUser -Name $NewAdminName
        Write-Output "Administrator account renamed to '$NewAdminName' and enabled."
        exit 0 # Exit with success code
    } else {
        Write-Error "Administrator account not found."
        exit 1 # Exit with failure code if Administrator account is missing
    }
} catch {
    Write-Error "Failed to configure Administrator account: $_"
    exit 1 # Exit with failure code if renaming or enabling fails
}
