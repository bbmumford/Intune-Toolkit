# Variables
$thirtyDaysAgo = (Get-Date).AddDays(-30)
$sixtyDaysAgo = (Get-Date).AddDays(-60)
$maxUsageMB = 10240 # Expected maximum disk usage (10 GB)

# Function to check and handle incorrect disk usage for system protection
function Check-MaxDiskUsage {
    Write-Output "Checking maximum disk usage for system protection..."
    $vssAdminOutput = & vssadmin list shadowstorage 2>&1
    if ($vssAdminOutput -match "For volume: C:\\") {
        $currentUsage = ($vssAdminOutput -match "Maximum size:.*?(\d+,\d+ MB)" | Out-String) -replace "[^\\d,]", ""
        $currentUsageMB = [int]($currentUsage -replace ",", "")
        Write-Output "Current maximum usage for system protection: $currentUsageMB MB."
        if ($currentUsageMB -eq $maxUsageMB) {
            return $true
        } else {
            Write-Output "Maximum disk usage for system protection is not set to $maxUsageMB MB."
            Write-Output "Disabling system protection to allow remediation to reset it..."
            Disable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
            return $false
        }
    } else {
        Write-Output "Shadow storage details for C:\\ could not be retrieved."
        Write-Output "Disabling system protection to allow remediation to reset it..."
        Disable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        return $false
    }
}

# Function to Check if System Protection is Enabled
function Check-SystemProtection {
    Write-Output "Checking if system protection is enabled on C:\\..."
    try {
        # Attempt WMI query
        $shadowStorage = Get-WmiObject -Namespace "root\cimv2" -Class "Win32_ShadowStorage" |
            Where-Object { $_.Volume -eq "C:\\" }
        if ($shadowStorage) {
            Write-Output "System protection is enabled with shadow storage configured (via WMI)."
            return $true
        }
    } catch {
        Write-Output "WMI check failed: $_"
        Write-Output "Falling back to vssadmin for system protection validation..."
    }

    # Fallback to vssadmin
    $vssAdminOutput = & vssadmin list shadowstorage 2>&1
    if ($vssAdminOutput -match "For volume: C:\\") {
        Write-Output "System protection is enabled with shadow storage configured (via vssadmin)."
        return $true
    } else {
        Write-Output "System protection is not enabled."
        return $false
    }
}

# Validate System Protection
if (-not (Check-SystemProtection)) {
    Write-Output "System protection is not enabled. Exiting detection script."
    exit 1
}

try {
    # Verify maximum disk usage for system protection
    if (-not (Check-MaxDiskUsage)) {
        Write-Output "Disk usage configuration for system protection is incorrect."
        exit 1
    }

    $needsRestorePoint = $true
    $needsCleanup = $false

    # Analyze existing restore points
    Write-Output "Analyzing existing restore points..."
    $restorePoints = Get-ComputerRestorePoint -ErrorAction SilentlyContinue
    if (-not $restorePoints) {
        Write-Output "No restore points exist. A new restore point is needed."
        exit 1
    }

    foreach ($restorePoint in $restorePoints) {
        Write-Output "Raw CreationTime: $($restorePoint.CreationTime)"
        try {
            $restoreTime = [DateTime]::ParseExact($restorePoint.CreationTime, "yyyyMMddHHmmss.ffffff-000", $null)
            Write-Output "Parsed restore point creation time: $restoreTime"
        } catch {
            Write-Output "Failed to parse CreationTime: $($restorePoint.CreationTime). Skipping entry."
            continue
        }

        # Check if the newest restore point is within 30 days
        if ($restoreTime -ge $thirtyDaysAgo) {
            Write-Output "A valid restore point exists (created on $restoreTime)."
            $needsRestorePoint = $false
        }

        # Check if there are restore points older than 60 days
        if ($restoreTime -lt $sixtyDaysAgo) {
            Write-Output "Restore point older than 60 days found (created on $restoreTime)."
            $needsCleanup = $true
        }
    }

    # Determine detection status
    if ($needsRestorePoint -or $needsCleanup) {
        Write-Output "Remediation is required: New restore point needed or cleanup required."
        exit 1
    }

    Write-Output "All conditions are met. No remediation needed."
    exit 0
} catch {
    Write-Output "Error occurred during detection: $_"
    exit 1
}
