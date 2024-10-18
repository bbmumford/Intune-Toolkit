### Usage
To use this script, pass the download URL and additional installer arguments as parameters. For example:

`powershell.exe -ExecutionPolicy Bypass -File ".\MSI_Application_Downloader&Installer.ps1" -DownloadUrl "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7BA7E4480B-E7CE-93D3-C349-B3AA2D62E60D%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dtrue%26ap%3Dx64-stable-statsdef_0%26brand%3DGCEA/dl/chrome/install/googlechromestandaloneenterprise64.msi" -InstallerArgs "/q /l"`

#### Explanation

Parameters:
- DownloadUrl: The URL from which to download the MSI file.
- InstallerArgs: Additional arguments to pass to the MSI installer.

Functions:
- Download-File: Downloads the file from the specified URL to a specified output path.
- Install-Application: Installs the application using the downloaded MSI file and additional arguments. The MSI installer (msiexec.exe) is used, and it includes the /qn flag for quiet mode and /norestart to prevent automatic restart.

Main Script:
- Downloads the MSI file to the temporary directory.
- Installs the application with the additional arguments.
- Cleans up by removing the downloaded MSI file.
