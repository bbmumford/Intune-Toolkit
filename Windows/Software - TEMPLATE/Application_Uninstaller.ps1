param(
    [string]$AppName
)

# Define success and failure exit codes
$ExitCode_Success = 0
$ExitCode_AppNotFound = 1
$ExitCode_UninstallFailed = 2

try {
    # Define registry paths where application GUIDs are stored
    $RegistryPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    $AppFound = $false
    $AppGUID = $null
    $UninstallString = $null

    # Search for the application in registry paths
    foreach ($Path in $RegistryPaths) {
        $Apps = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue |
                ForEach-Object {
                    Get-ItemProperty -Path $_.PSPath
                } | Where-Object { $_.DisplayName -like "*$AppName*" }

        if ($Apps) {
            $AppFound = $true
            $AppGUID = $Apps.PSChildName
            $UninstallString = $Apps.UninstallString
            Write-Host "Application found in registry: $($Apps.DisplayName)"
            break
        }
    }

    if ($AppFound) {
        # Modify the uninstall string to ensure silent operation and no restart
        if ($UninstallString -match "msiexec") {
            $UninstallString += " /quiet /norestart"
        } elseif ($UninstallString -match "setup.exe" -or $UninstallString -match "uninstall.exe") {
            $UninstallString += " /S /norestart"
        } else {
            Write-Host "Uninstall string not recognized or does not support silent uninstall: $UninstallString"
            exit $ExitCode_UninstallFailed
        }

        Write-Host "Uninstall command: $UninstallString"

        # Execute the uninstall command silently
        $Process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $UninstallString -Wait -NoNewWindow -PassThru
        if ($Process.ExitCode -eq 0) {
            Write-Host "Application uninstalled successfully."
            exit $ExitCode_Success
        } else {
            Write-Host "Uninstallation failed with exit code: $($Process.ExitCode)"
            exit $ExitCode_UninstallFailed
        }
    } else {
        Write-Host "Application not found in registry: $AppName"
        Write-Host "Attempting to uninstall using WMIC..."

        # Fallback to WMIC for uninstall
        $WMICCommand = "wmic product where ""name like '$AppName%'"" call uninstall /nointeractive"
        $Process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $WMICCommand -Wait -NoNewWindow -PassThru

        if ($Process.ExitCode -eq 0) {
            Write-Host "Application uninstalled successfully using WMIC."
            exit $ExitCode_Success
        } else {
            Write-Host "Uninstallation via WMIC failed with exit code: $($Process.ExitCode)"
            exit $ExitCode_UninstallFailed
        }
    }
} catch {
    Write-Host "An error occurred: $($_.Exception.Message)"
    exit $ExitCode_UninstallFailed
}
