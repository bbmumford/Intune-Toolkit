        ____      __                                           ____  _____
       /  _/___  / /___  ______  ___     ____ ___  ____ ______/ __ \/ ___/
       / // __ \/ __/ / / / __ \/ _ \   / __ `__ \/ __ `/ ___/ / / /\__ \ 
     _/ // / / / /_/ /_/ / / / /  __/  / / / / / / /_/ / /__/ /_/ /___/ / 
    /___/_/ /_/\__/\__,_/_/ /_/\___/  /_/ /_/ /_/\__,_/\___/\____//____/  
                                                                      

# Intune macOS Shell Script Samples

This repository is for macOS Intune sample scripts and custom configuration profiles. There are many cases where it is necessary to use a custom profile or shell script to accomplish a task.

To get started, check out the following documentation
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

To make things a little easier to navigate the repo has been split up into three main sections:

For instructions on configuring & linking Apple Business Manager to Intune, see [this guide](ABM_to_Intune_Configuration.md).

For instructions on hwo to deploy & manage apps from ABM VPP with Intune, see [this guide](VPP_with_Intune_Configuration.md).


## Apps

This section is for scripts that install or configure applications on the Mac. There are many reasons to deploy apps via shell script rather than via the macOS mdmclient. Our preferred method of app deployment is via the [Mac App Store VPP](https://docs.microsoft.com/en-us/mem/intune/apps/vpp-apps-ios), but the Intune Scripting agent provides an almost infinte level of possibilities where the apps you need on your Macs can't be deployed via VPP.

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

## Configuations

This section is for scripts that do general macOS configurations. This is an Alladin's cave of scripts to get your Macs in shape. Feel free to submit your own examples too, we'd love to get contributions.

```
   |-Script - Configure
   |---Rename Device
   |---Dock
   |---Admin System-Wide Preferences Access
   |---Accounts
   |---FileVault
   |------Backup FileVault Keys to Intune
   |-Configure
   |---Microsoft Edge Favourites

```
`
