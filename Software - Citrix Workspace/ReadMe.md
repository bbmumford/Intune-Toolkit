
Usage
To use this script, pass the download URL and additional installer arguments as parameters. For example:

powershell.exe -ExecutionPolicy Bypass -File .\EXE_Applcation_Downloader&Installer.ps1 -DownloadUrl "https://downloads.citrix.com/22748/CitrixWorkspaceApp.exe?__gda__=exp=1721711894~acl=/*~hmac=0461d232e2332ce9d1981ad51970a54418d7cf3b9e75990f8be80cb2fbe8940b" -InstallerArgs "/silent AutoUpdateStream=LTSR STORE0=HDS;https://hds.bamits.com.au/discovery;on;HDS"



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


To Uninstall:
