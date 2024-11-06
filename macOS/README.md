        ____      __                                           ____  _____
       /  _/___  / /___  ______  ___     ____ ___  ____ ______/ __ \/ ___/
       / // __ \/ __/ / / / __ \/ _ \   / __ `__ \/ __ `/ ___/ / / /\__ \ 
     _/ // / / / /_/ /_/ / / / /  __/  / / / / / / /_/ / /__/ /_/ /___/ / 
    /___/_/ /_/\__/\__,_/_/ /_/\___/  /_/ /_/ /_/\__,_/\___/\____//____/  
                                                                      

# Intune macOS Shell Script Samples

This part of the repository is for macOS Intune collected scripts and configuration profiles.

## Prerequisites
- [Configuring & linking Apple Business Manager to Intune](GUIDE_ABM_to_Intune_Configuration.md)

### Additional Guides:

- [Deploy & manage apps from ABM VPP with Intune](GUIDE_VPP_with_Intune_Configuration.md)

- [Configure Device login via Entra SSO](GUIDE_VPP_with_Intune_Configuration.md)

## Apps - Script Deployed

Typically apps are deployed via the [Mac App Store VPP](https://docs.microsoft.com/en-us/mem/intune/apps/vpp-apps-ios), alternatively Microsoft has developed some very thorough scripts (with some modifications from myself.)

```
   |-Script - Install
   |---Asana
   |---Bitdefender
   |---Citrix Workspace
   |---Company Portal
   |---Defender
   |---Edge
   |---Google Chrome
   |---Google Drive
   |---Remote Desktop
   |---Slack
   |---Teams
   |---TeamViewer
   |---Zoom
```

## Configurations -  Script Deployed

Potential configurations managed via script.

```
   |-Script - Configure
   |---Admin System-Wide Preferences Access
   |---Dock
   |---Enable FileVault
   |------Backup FileVault Keys to Intune
   |---Local Accounts
   |---Rename Device

```

## Configurations - MobileConfig

Potential configurations managed via macOS mobile configuration profiles.

```
   |-Configure
   |---Microsoft Edge - Managed Favourites
   |---Wallpaper

```


## Microsoft Guides
For additional configuration guides, check out the following Microsoft documentation.
- [Set up enrollment for macOS devices in Intune](https://docs.microsoft.com/en-us/mem/intune/enrollment/macos-enroll)
- ***[Use shell scripts on macOS devices in Intune](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts)***
- [macOS settings to mark devices as compliant or not compliant using Intune](https://docs.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-mac-os)
- [macOS device settings to allow or restrict features using Intune](https://docs.microsoft.com/en-us/mem/intune/configuration/device-restrictions-macos)
- [Add macOS system and kernel extensions in Intune](https://docs.microsoft.com/en-us/mem/intune/configuration/kernel-extensions-overview-macos)
- [Add a property list file to macOS devices using Microsoft Intune](https://docs.microsoft.com/en-us/mem/intune/configuration/preference-file-settings-macos)
- [Add and use wired networks settings on your macOS devices in Microsoft Intune](https://docs.microsoft.com/en-us/mem/intune/configuration/wired-networks-configure)
- [Create a profile with custom settings in Intune](https://docs.microsoft.com/en-us/mem/intune/configuration/custom-settings-configure)
- [Add iOS, iPadOS, or macOS device feature settings in Intune](https://docs.microsoft.com/en-us/mem/intune/configuration/device-features-configure)
- [How to manage iOS and macOS apps purchased through Apple Volume Purchase Program with Microsoft Intune](https://docs.microsoft.com/en-us/mem/intune/apps/vpp-apps-ios)