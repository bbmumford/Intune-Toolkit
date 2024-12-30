# Define the expected administrator account name
$ExpectedAdminName = "Company.LocalAdmin"

# Find all local accounts
$AllAccounts = Get-LocalUser

# Find the default Administrator account (SID ending in -500)
$AdminAccount = $AllAccounts | Where-Object { $_.SID -like "S-1-5-*-500" }

# Find other accounts with the same name as the expected administrator
$DuplicateAccounts = $AllAccounts | Where-Object { $_.Name -eq $ExpectedAdminName -and $_.SID -ne $AdminAccount.SID }

# Check if the default Administrator account exists
if ($AdminAccount) {
    if ($AdminAccount.Name -eq $ExpectedAdminName -and $AdminAccount.Enabled) {
        if ($DuplicateAccounts) {
            Write-Error "Non-Compliant: Duplicate account(s) with name '$ExpectedAdminName' found."
            exit 1 # Failure - Non-Compliant
        } else {
            Write-Output "Compliant: Administrator account is properly configured."
            exit 0 # Success - Compliant
        }
    } else {
        Write-Error "Non-Compliant: Administrator account is not properly configured."
        exit 1 # Failure - Non-Compliant
    }
} else {
    Write-Error "Non-Compliant: Administrator account not found."
    exit 1 # Failure - Non-Compliant
}
