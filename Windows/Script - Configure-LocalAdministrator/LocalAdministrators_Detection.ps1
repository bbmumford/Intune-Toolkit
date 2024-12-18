# Define the expected administrator account name
$ExpectedAdminName = "Company.LocalAdmin"

# Find the Administrator account (SID ending in -500)
$AdminAccount = Get-LocalUser | Where-Object { $_.SID -like "S-1-5-*-500" }

# Check if the account exists
if ($AdminAccount) {
    # Check if the account is renamed and enabled
    if ($AdminAccount.Name -eq $ExpectedAdminName -and $AdminAccount.Enabled) {
        Write-Output "Compliant: Administrator account is renamed to '$ExpectedAdminName' and enabled."
        exit 0 # Success - Compliant
    } else {
        Write-Error "Non-Compliant: Administrator account is not renamed or not enabled."
        exit 1 # Failure - Non-Compliant
    }
} else {
    Write-Error "Non-Compliant: Administrator account not found."
    exit 1 # Failure - Non-Compliant
}
