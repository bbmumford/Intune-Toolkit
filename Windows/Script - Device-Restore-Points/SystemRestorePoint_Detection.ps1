# Detect if there are valid restore points and if they are older than 30 days
$restorePoints = Get-ComputerRestorePoint | Sort-Object -Property CreationTime -Descending
$lastRestorePoint = $restorePoints | Select-Object -First 1
$thirtyDaysAgo = (Get-Date).AddDays(-30)

if (-not $restorePoints) {
    # No restore points exist
    Write-Output "No restore points exist."
    exit 1
} elseif ($lastRestorePoint.CreationTime -lt $thirtyDaysAgo) {
    # Last restore point is older than 30 days
    Write-Output "Last restore point is older than 30 days."
    exit 1
} else {
    # A valid restore point exists
    Write-Output "A valid restore point exists."
    exit 0
}
