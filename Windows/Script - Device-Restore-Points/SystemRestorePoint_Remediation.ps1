# Variables
$restorePointDescription = "Restore Point Created by Intune Remediation Script"
$restorePointType = "MODIFY_SETTINGS" # Valid type for routine tasks
$sixtyDaysAgo = (Get-Date).AddDays(-60)

try {
    # Enable system protection on the C:\ drive
    Write-Output "Enabling system protection for C:\..."
    Enable-ComputerRestore -Drive "C:\" -ErrorAction Stop
    Write-Output "System protection enabled successfully."

    # Remove restore points older than 60 days
    Write-Output "Checking for restore points older than 60 days..."
    $restorePoints = Get-ComputerRestorePoint | Where-Object { $_.CreationTime -lt $sixtyDaysAgo }
    foreach ($restorePoint in $restorePoints) {
        # Remove the restore point
        $restorePointID = $restorePoint.SequenceNumber
        Write-Output "Removing restore point with ID $restorePointID..."
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($restorePoint) | Out-Null
        Remove-ComputerRestorePoint -SequenceNumber $restorePointID -ErrorAction Continue
    }
    Write-Output "Old restore points removed."

    # Create a new restore point
    Write-Output "Creating a new system restore point..."
    Checkpoint-Computer -Description $restorePointDescription -RestorePointType $restorePointType -ErrorAction Stop
    Write-Output "New restore point created successfully."
    exit 0
} catch {
    Write-Output "Error: $_"
    exit 1
}
