## Usage
To use this script, pass the download URL and additional installer arguments as parameters. For example:

`powershell.exe -ExecutionPolicy Bypass -File .\Bitdefender_Downloader&Installer.ps1 -DownloadUrl "https://download.bitdefender.com/SMB/Hydra/release/bst_win/downloaderWrapper/BEST_downloaderWrapper.msi" -PackageID "aHR0cH-bGFuZ41lbi1VUw=="`

Setting Client PackageID:
1. Log in to GravityZone Control Center.
2. Navigate to `Network` > `Packages`
3. Select the installation package you want to download.

> [!CAUTION] 
> This procedure currently does not support installation packages with proxy settings.

1. Click Download at the upper side of the table and select Windows Downloader.

The installation package is saved to your default download location as an EXE file.
You will need details from the downloaded files name.
Installation package name:
```
setupdownloader_[aHR0cH-bGFuZ41lbi1VUw==].exe
GZ_PACKAGE_ID value:
aHR0cH-bGFuZ41lbi1VUw==
```

## Explanation

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