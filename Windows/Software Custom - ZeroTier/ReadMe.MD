Usage
To use this script, pass the download URL and additional installer arguments as parameters. 
For example:

powershell.exe -ExecutionPolicy Bypass -File ".\Install_ZeroTier.ps1" -Token "API TOKEN HERE" -NetworkID "NETWORK ID"

Explanation
The following scripts download, install & autherize ZeroTier devices on provided networks.

Notes
    This script will install PowerShell 7 if it is not present.
    A UAC prompt will appear during install if -UI is used. NOT RECOMMENDED FOR INTUNE.

