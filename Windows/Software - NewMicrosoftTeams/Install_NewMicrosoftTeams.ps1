# Define paths and filenames
$msixFile = "$env:temp\MSTeams-x64.msix"
$msixUrl = "https://go.microsoft.com/fwlink/?linkid=2196106"
$bootstrapperPath = ".\teamsbootstrapper.exe"

# Download MSTeams-x64.msix to the temp directory
try {
    Invoke-WebRequest -Uri $msixUrl -OutFile $msixFile
    Write-Host "MSTeams-x64.msix downloaded successfully."
} catch {
    Write-Host "Error: Failed to download MSTeams-x64.msix."
    exit 1
}

# Check if the download operation was successful
if (Test-Path -Path $msixFile) {
    # If successful, execute teamsbootstrapper.exe with specified parameters
    Start-Process -FilePath $bootstrapperPath -ArgumentList "-p", "-o", $msixFile -Wait -WindowStyle Hidden
    Write-Host "Microsoft Teams installation completed successfully."
} else {
    # If download operation failed, display an error message
    Write-Host "Error: MSTeams-x64.msix file not found."
    exit 1
}
