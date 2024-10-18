### Usage
To use this script, pass the download URL and additional installer arguments as parameters. For **example:**

`powershell.exe -ExecutionPolicy Bypass -File ".\Application_Downloader&Installer.ps1" -DownloadUrl "DOWNLOAD_LINK_HERE" -InstallerArgs "/qn /norestart"`

#### Explanation

Parameters:
- DownloadUrl: The URL from which to download the MSI or EXE file.
- InstallerArgs: Additional arguments to pass to the installer.

Functions:
- Download-File: Downloads the file from the specified URL to a specified output path
- Install-Application: Installs the application using the downloaded MSI or EXE file and additional arguments.

Main Script:
- Downloads the file to the temporary directory.
- Installs the application with the additional arguments.
- Cleans up by removing the downloaded file.
