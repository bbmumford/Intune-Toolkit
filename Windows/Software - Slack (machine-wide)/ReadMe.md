Usage
To use this script, pass the download URL and additional installer arguments as parameters. For example:

powershell.exe -ExecutionPolicy Bypass -File ".\MSI_Application_Downloader&Installer.ps1" -DownloadUrl "https://slack.com/ssb/download-win64-msi" -InstallerArgs "INSTALLLEVEL=2 /qn /norestart"

Explanation

Parameters:
    DownloadUrl: The URL from which to download the MSI file.
    InstallerArgs: Additional arguments to pass to the MSI installer.

Functions:
    Download-File: Downloads the file from the specified URL to a specified output path.
    Install-Application: Installs the application using the downloaded MSI file and additional arguments. The MSI installer (msiexec.exe) is used, and it includes the /qn flag for quiet mode and /norestart to prevent automatic restart.

Main Script:
    Downloads the MSI file to the temporary directory.
    Installs the application with the additional arguments.
    Cleans up by removing the downloaded MSI file.
