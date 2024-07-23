Usage
To use this script, pass the download URL and additional installer arguments as parameters. For example:

powershell.exe -ExecutionPolicy Bypass -File .\EXE_Applcation_Downloader&Installer.ps1 -DownloadUrl "https://desktop-downloads.asana.com/win32_x64/prod/latest/AsanaSetup.exe" -InstallerArgs "/s"


Explanation


Parameters:
    DownloadUrl: The URL from which to download the executable.
    InstallerArgs: Additional arguments to pass to the installer.


Functions:
    Download-File: Downloads the file from the specified URL to a specified output path.
    Install-Application: Installs the application using the downloaded executable and additional arguments.


Main Script:
    Downloads the executable to the temporary directory.
    Installs the application with the additional arguments.
    Cleans up by removing the downloaded executable.

Run As User


To Uninstall:
    %USERPROFILE%\AppData\Local\Asana\Update.exe" --uninstall