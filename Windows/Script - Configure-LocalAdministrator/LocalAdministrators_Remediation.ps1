# Define the expected administrator account name
$NewAdminName = "Company.LocalAdmin"

# Find the local Administrator account
$AdminAccount = Get-LocalUser | Where-Object { $_.SID -like "S-1-5-*-500" }

# Rename and enable the Administrator account
if ($AdminAccount) {
    Rename-LocalUser -Name $AdminAccount.Name -NewName $NewAdminName
    Enable-LocalUser -Name $NewAdminName
    Write-Output "Administrator account renamed to '$NewAdminName' and enabled."
} else {
    Write-Error "Administrator account not found."
}
