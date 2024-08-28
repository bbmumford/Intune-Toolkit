# Define the URL of the file to download
$FileUrl = "https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/master/MAS/Separate-Files-Version/Activators/HWID_Activation.cmd"
# Define the local path where the file will be saved
$LocalFilePath = "$env:TEMP\HWID_Activation.cmd"

# Download the file
Invoke-WebRequest -Uri $FileUrl -OutFile $LocalFilePath

# Check if the file exists
if (Test-Path $LocalFilePath) {
    # Execute the downloaded file with the /HWID parameter
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c $LocalFilePath /HWID" -Wait
    
    # Remove the file after execution
    Remove-Item -Path $LocalFilePath -Force
} else {
    Write-Output "Failed to download the file."
}

