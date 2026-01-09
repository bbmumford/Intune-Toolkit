<#
.SYNOPSIS
    Intune Remediation - Remediation Script for Background Image
    
.DESCRIPTION
    Downloads the background image and updates the local version registry key.
#>

# --- Configuration ---
# Update this version number to match the Detection script
$Version = "1.0"

$ImageUrl = "https://raw.githubusercontent.com/HSTLES/shared-assets/b805564a62e7a3bfa866cba3e8c74ee17aad63a7/media/clients/icn/icn_background.png"
$LocalDirectory = "C:\ProgramData\Intune"
$LocalFileName = "background.png"
$RegPath = "HKLM:\SOFTWARE\Intune"
$RegName = "BackgroundImageVersion"
# ---------------------

$LocalFilePath = Join-Path -Path $LocalDirectory -ChildPath $LocalFileName

try {
    # 1. Create Directory if needed
    if (-not (Test-Path -Path $LocalDirectory)) {
        Write-Output "Creating directory: $LocalDirectory"
        New-Item -Path $LocalDirectory -ItemType Directory -Force | Out-Null
    }

    # 2. Download File
    Write-Output "Downloading image (Version $Version)..."
    Invoke-WebRequest -Uri $ImageUrl -OutFile $LocalFilePath -UseBasicParsing

    if (-not (Test-Path -Path $LocalFilePath)) {
        throw "Download failed - file not found after download attempt."
    }

    # 3. Update Registry Version
    if (-not (Test-Path -Path $RegPath)) {
        New-Item -Path $RegPath -ItemType Directory -Force | Out-Null
    }
    New-ItemProperty -Path $RegPath -Name $RegName -Value $Version -PropertyType String -Force | Out-Null

    Write-Output "Remediation Successful: Downloaded version $Version to $LocalFilePath"

} catch {
    Write-Error "Remediation Failed: $($_.Exception.Message)"
    exit 1
}
