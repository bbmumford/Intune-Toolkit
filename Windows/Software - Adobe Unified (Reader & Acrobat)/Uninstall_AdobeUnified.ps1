$ProductName = "Adobe Acrobat DC"
$UninstallKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$TempPath = "$env:TEMP\AcrobatUninstall"

# Function to find the Uninstall String
function Get-UninstallString {
    Write-Host "Searching for $ProductName in installed programs..." -ForegroundColor Green
    $uninstallString = Get-ChildItem -Path $UninstallKeyPath |
        Where-Object { (Get-ItemProperty $_.PSPath).DisplayName -like "*$ProductName*" } |
        ForEach-Object { (Get-ItemProperty $_.PSPath).UninstallString }

    if (!$uninstallString) {
        Write-Error "$ProductName is not installed or cannot be found."
        exit 1
    }

    return $uninstallString
}

# Fetch the Uninstall String
$UninstallString = Get-UninstallString

# Adjust Uninstall String if required
if ($UninstallString -like "*.exe*") {
    $UninstallCommand = "$UninstallString /s"
} elseif ($UninstallString -like "*.msi*") {
    $UninstallCommand = "msiexec /x $UninstallString /qn"
} else {
    Write-Error "Unsupported uninstall string format."
    exit 1
}

# Run the Uninstall Command
Write-Host "Uninstalling $ProductName silently..." -ForegroundColor Green
Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $UninstallCommand -Wait -NoNewWindow

# Cleanup registry keys
Write-Host "Removing registry keys..." -ForegroundColor Green
Remove-Item -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat\DC\FeatureLockDown" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat\DC" -Recurse -Force -ErrorAction SilentlyContinue

# Confirm uninstallation
Write-Host "$ProductName uninstallation complete!" -ForegroundColor Cyan
