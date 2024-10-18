        ____      __                     _       ___           __                  
       /  _/___  / /___  ______  ___    | |     / (_)___  ____/ /___ _      _______
       / // __ \/ __/ / / / __ \/ _ \   | | /| / / / __ \/ __  / __ \ | /| / / ___/
     _/ // / / / /_/ /_/ / / / /  __/   | |/ |/ / / / / / /_/ / /_/ / |/ |/ (__  ) 
    /___/_/ /_/\__/\__,_/_/ /_/\___/    |__/|__/_/_/ /_/\__,_/\____/|__/|__/____/  
                                                                      
  
# Pre-Requisites
  ## Enabling Temporary Access Password (TAP) in Microsoft Intune

  Temporary Access Password (TAP) allows users to gain temporary access to their devices when they are locked out, without requiring intervention from IT support. This guide outlines the steps to enable and configure TAP in Microsoft Intune.

  ### Steps to Enable TAP

  #### 1. **Open Microsoft Endpoint Manager Admin Center**

  1. Go to [Microsoft Endpoint Manager Admin Center](https://endpoint.microsoft.com/).
  2. Sign in with your admin credentials.

  #### 2. **Navigate to Device Enrollment**

  1. In the Microsoft Endpoint Manager Admin Center, go to `Devices` > `Enroll devices`.
  2. Click `Enrollment Program Tokens`.

  #### 3. **Create or Edit an Enrollment Program Token**

  1. If you don't already have an Enrollment Program Token, click `+ Create`.
  2. If you have an existing token, click on it to edit.

  #### 4. **Enable TAP**

  1. **Find and Configure TAP Settings**
    - Within the Enrollment Program Token settings, locate the `Temporary Access Password` section.
    - Enable TAP by toggling the switch to `On`.

  2. **Configure TAP Settings**
    - **Duration**: Set the duration for which the TAP will be valid.
    - **Password Complexity**: Define the complexity requirements for the TAP.
    - **Number of Attempts**: Specify the number of allowed attempts before a user must contact support.

  #### 5. **Save and Apply**

  1. Click `Save` to apply the TAP settings.
  2. Ensure that the updated token settings are applied to your devices.


## Enable Windows Diagnostic Data and Licensing Usage

1. **Navigate to Connectors and Tokens**
   - Go to `Tenant Administration` > `Connectors and tokens`.

2. **Configure Windows Data Settings**
   - Click on the `Windows data` node.
   - Here you can configure your tenant to support Windows diagnostic data in processor configuration.

   **Note:** 
   - Enabling the Windows Diagnostic setting will activate Intune features powered by Windows diagnostic data.
   - It will also enable the Windows diagnostic data processor configuration if your tenant is not already opted-in.

3. **Confirm Licensing Requirements**
   - An Intune Service Administrator must confirm licensing requirements before using the Windows 11 Upgrade Readiness report and proactive remediations for the first time.
   - To use these features, confirm your tenant has one of the following licenses. You must be a Global Administrator or Intune Service Administrator to confirm licenses:

     - Windows 10 or later Enterprise E3 or E5; or Microsoft 365 F3, E3, or E5
     - Windows 10 or later Education A3 or A5; or Microsoft 365 A3 or A5
     - Windows Virtual Desktop Access E3 or E5

   - Set `I confirm that my tenant owns one of these licenses` to `On`.




# Setup AutoPilot / Enrolment
  ## Import HASH Keys for automatic enrolment
  Importing HASH Keys allows a device to be assigned to a Tenant upon the devices connection to the internet & persist association after reset, this must specificly requested before ordering devices.

  Alternativly you can extract the HASH Key from exising devices using scrips (see scripts containted within the folder `Configure - Importing HASH Keys`)
  Run the CMD script on a connected USB & it will update a CSV file it creates in the same directory, updating with each machine it is run on.
  The script will attempt to automaticly import the new HASH Key if Intune administrator details are provided when prompted.

  [Read the guide on how to manually import keys](Configure%20-%20Importing%20HASH%20Keys/GUIDE_Import_HASH_Keys.md)

  ## Create Dynamic Enrolemnt Group
  1. **Create a group on Azure AD Home**
  - Click on `Groups` > `New Group` > `Group Type` 
  - Select `Security` > Give a name and group description. 
  - Select `Membership Type` as `Dynamic Device`
  - Under Advanced rule for Add dynamic query, add `(device.devicePhysicalIDs -any (_ -contains "[ZTDID]"))` or 
  `see table below` then click Add query. 

  Once done, a group will be created and all the AutoPilot device will get added into it.

| Devices                                                   | Query                                                      |
|---------------------------------------------------------------|------------------------------------------------------------|
| All Windows AutoPilot devices                                 | `(device.devicePhysicalIDs -any _ -contains “[ZTDId]”)`   |
| All Windows AutoPilot devices with a specific order Id      | `(device.devicePhysicalIds -any _ -eq “[OrderID]:{YourOrderId}”)` |
| All Windows AutoPilot devices with a specific purchase order Id | `(device.devicePhysicalIds -any _ -eq “[PurchaseOrderId]:{YourPurchaseOrderId }”)` |

# Standard Device Configuration
- [Create a Local Administartor Account](Configure%20-%20Local%20Admin/GUIDE_Create_Local_Administrator.md)
- [Enable LAPS for password managemnt](GUIDE_Intune_LAPS_Guide.md)
- [Configure WiFi](Configure%20-%20Wi-Fi/GUIDE_Configure_WiFi.md)
- [Configure Desktop Background](Configure%20-%20Background%20Image/GUIDE_Setup_Background_Images.md)
  This is dependent on the `Software Custom - IntuneDependencies` package.
- [Configure Taskbar](Configure%20-%20Taskbar/GUIDE_Configure_Taskbar.md)
  Deploy injunction with software.
- **Recommended System Software**
```
   |-Software Custom
   |---DesktopInfo
   |---ExplorerPatcher
   |---IntuneDependencies
   |---LoadingScreen (per user)
   |---Managed Printers
   |---ZeroTier
```
- **Recommended System Remediation Scripts**
```
   |-Script
   |---Clear-TeamsCache
   |---Configure-ExplorerPatcher
   |---Device-Auto-Syncer
   |-Configure
   |---OneDrive (silent sync)
```

# Deploying Applications
- [Dynamic Groups for Targeted Deployment](GUIDE_Entra_Profile_Location_Based_Dynamic_Groups.md)
Use Case: Office or Department based application or printer deployment.
- **General Deployables**
```
   |-Software
   |---Asana
   |---Bitdefender
   |---Citrix Workspace
   |---Google Chrome
   |---Slack
   |---Teams
```
See `Software - TEMPLATE` for a base script to use / package when deploying software to Intune, it supports .msi & .exe

- Microsoft Office: Deploy via Intune Microsoft Store.
- **Deployable Additionals**
```
   |-Configure
   |---Add Chrome or Edge Extensions
   |-----Tab Suspender
   |-----Tab Limiter

or

   |-Script
   |---Install Chrome or Edge Extensions
   |-----Tab Suspender
   |-----Tab Limiter
```