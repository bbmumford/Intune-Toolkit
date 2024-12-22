        ____      __                     _       ___           __                  
       /  _/___  / /___  ______  ___    | |     / (_)___  ____/ /___ _      _______
       / // __ \/ __/ / / / __ \/ _ \   | | /| / / / __ \/ __  / __ \ | /| / / ___/
     _/ // / / / /_/ /_/ / / / /  __/   | |/ |/ / / / / / /_/ / /_/ / |/ |/ (__  ) 
    /___/_/ /_/\__/\__,_/_/ /_/\___/    |__/|__/_/_/ /_/\__,_/\____/|__/|__/____/  
                                                                      
# Recommended Intune Configuration Guide

This guide provides a step-by-step approach to configuring Microsoft Intune. It covers pre-requisites, AutoPilot preparation, device configuration, and deploying applications. Use this as a baseline for organizational Intune configurations.

---

## Table of Contents

1. [Pre-Requisites](#1-pre-requisites)
   - [Enable Temporary Access Password (TAP)](#enabling-temporary-access-password-tap)
   - [Enable Windows Diagnostic Data](#enable-windows-diagnostic-data-and-licensing-usage)
2. [Setup AutoPilot and Enrollment](#2-setup-autopilot-and-enrollment)
   - [Import HASH Keys](#import-hash-keys-for-automatic-enrolment)
   - [Create Dynamic Enrollment Group](#create-dynamic-enrollment-group)
   - [Choosing Between Preparation and Deployment Profiles](#choosing-between-preparation-and-deployment-profiles)
   - [Option 1: Windows Autopilot Device Preparation](#option-1-windows-autopilot-device-preparation)
     - [Steps to Configure Device Preparation](#steps-to-configure-device-preparation)
     - [Device Preparation Flow](#device-preparation-flow)
   - [Option 2: Windows Autopilot Deployment Profile](#option-2-windows-autopilot-deployment-profile)
     - [Steps to Configure the Deployment Profile](#steps-to-configure-the-deployment-profile)
     - [Deployment Profile Flow](#deployment-profile-flow)
3. [Group Structure and Membership](#3-group-structure-and-membership)
   - [Dynamic Groups](#dynamic-groups)
   - [Static Groups](#static-groups)
   - [Nested Membership](#nested-membership)
4. [Standard Device Configuration](#4-standard-device-configuration)
5. [Deploying Applications (System)](#5-deploying-applications-system)
   - [General Deployables](#general-deployables)
   - [Deployable Additionals](#deployable-additionals)
6. [Deploying Applications (User)](#6-deploying-applications-user)
   - [Custom Loading Screen](#custom-loading-screen)
   - [User Deployables](#user-deployables)


---

## 1. Pre-Requisites

### **Enabling Temporary Access Password (TAP)**

1. **Open Microsoft Endpoint Manager Admin Center**  
   - Go to [Microsoft Endpoint Manager Admin Center](https://endpoint.microsoft.com/).  
   - Sign in with your admin credentials.

2. **Navigate to Device Enrollment**  
   - Go to `Devices > Enroll devices > Enrollment Program Tokens`.  
   - Edit or create a new Enrollment Program Token.

3. **Enable TAP**  
   - Locate the `Temporary Access Password` section.  
   - Toggle the switch to **On**.  

4. **Configure TAP Settings**  
   - **Duration**: Set password validity.  
   - **Password Complexity**: Define complexity rules.  
   - **Number of Attempts**: Specify retry attempts.

5. **Save and Apply**  
   - Click **Save** to apply the settings.

---

### **Enable Windows Diagnostic Data and Licensing Usage**

1. Navigate to `Tenant Administration > Connectors and tokens`.  
2. **Configure Windows Data Settings**
   - Click on the `Windows data` node.
   - Here you can configure your tenant to support Windows diagnostic data in processor configuration.
   **Note:** 
   - Enabling the Windows Diagnostic setting will activate Intune features powered by Windows diagnostic data.
   - It will also enable the Windows diagnostic data processor configuration if your tenant is not already opted-in.  
3. Confirm licensing requirements:  
  - An Intune Service Administrator must confirm licensing requirements before using the Windows 11 Upgrade Readiness report and proactive remediations for the first time.
  - To use these features, confirm your tenant has one of the following licenses. You must be a Global Administrator or Intune Service Administrator to confirm licenses:
    - Windows 10 or later Enterprise E3 or E5; or Microsoft 365 F3, E3, or E5
    - Windows 10 or later Education A3 or A5; or Microsoft 365 A3 or A5
    - Windows Virtual Desktop Access E3 or E5  
  - Set `I confirm that my tenant owns one of these licenses` to **On**.

---

## 2. Setup AutoPilot and Enrollment

### **Import HASH Keys for Automatic Enrolment**

Importing HASH Keys allows a device to be assigned to a Tenant upon the devices connection to the internet & persist association after reset. This must be specifically requested before ordering devices, or you can extract the HASH Key from existing devices using scripts (see scripts contained within the folder Configure - Importing HASH Keys).

1. **Pre-Requisite**: Obtain HASH Keys for devices before procurement.  
2. Use the script in `Configure - Importing HASH Keys` to extract HASH keys:  
   - Run the CMD script on a USB drive.  
   - The script generates a CSV file and updates it for each device.  
   - If prompted, enter **Intune administrator details** to automatically import keys.

[Read the detailed guide](Configure%20-%20Importing%20HASH%20Keys/GUIDE_Import_HASH_Keys.md).

---

### **Create Dynamic Enrollment Group**

See [Recommended Group Structure and Membership](#3-group-structure-and-membership) & the [Dynamic Groups for Targeted Deployment Guide](GUIDE_Entra_Profile_Location_Based_Dynamic_Groups.md) for additional group conditions.

1. Navigate to **Azure AD > Groups**.  
2. Create a new group:  
   - **Group Type**: Security  
   - **Membership Type**: Dynamic Device  
3. Add the query:  
   ```plaintext
   (device.devicePhysicalIDs -any _ -contains "[ZTDID]")
   ```

| Devices                                | Query Example                                                    |
|----------------------------------------|------------------------------------------------------------------|
| All AutoPilot devices                  | `(device.devicePhysicalIDs -any _ -contains “[ZTDId]”)`         |
| AutoPilot with specific Order ID       | `(device.devicePhysicalIds -any (_ -eq "[OrderID]:{OrderID}"))` |
| AutoPilot with specific Purchase Order | `(device.devicePhysicalIds -any _ -eq “[PurchaseOrderId]:{ID}"))` |

---

### **Choosing Between Preparation and Deployment Profiles**

| **Feature**                        | **Device Preparation**                 | **Deployment Profile**                 |
|------------------------------------|----------------------------------------|----------------------------------------|
| **Device Pre-Registration**        | Not Required                           | Required                               |
| **Supported Deployment Modes**     | User-driven only                       | User-driven, Self-deploying, Pre-provisioned |
| **Customization**                  | Limited (Apps, Scripts)                | Extensive (Naming, Settings, Scripts)  |
| **Supported OS Versions**          | Windows 11 (22H2 with KB5035942)       | Windows 10 and Windows 11              |
| **Device Naming**                  | Not Supported (script or app required) | Supported                              |
| **Ideal Use Case**                 | Simple and quick deployments           | Complex and customized deployments     |

---

### **Option 1: Windows Autopilot Device Preparation**

The **Windows Autopilot Device Preparation** option provides a simplified provisioning experience that applies essential settings, applications, and scripts during the **Out-of-Box Experience (OOBE)** phase. This option does not require device pre-registration in Autopilot.

#### **Steps to Configure Device Preparation**

1. **Navigate to Microsoft Intune Admin Center**:  
   - Go to **Devices > Windows > Windows enrollment > Device preparation policies**.  

2. **Create the Preparation Policy**:  
   - Click **+ Create profile**.  
   - **Name**: Set the descriptive profile name to **`Device_Preparation`**.  

3. **Device Group Assignment**:  
   - In the **Device group** step, assign the policy to the **`Intune_Devices_Enrolled`** group.  

4. **Configure Deployment Settings**:  
   - **Deployment mode**: Select **User-driven**.  
   - **Join type**: Select **Microsoft Entra joined**.  
   - **User account type**: Set to **Standard User**.  

5. **Configure OOBE Settings**:  
   - **Language (Region)**: Specify the default language and region.  
   - **Privacy settings**: Hide privacy options during OOBE.  
   - **License Terms**: Suppress Microsoft Software License Terms.  

6. **Select Preparation Applications and Scripts**:  
   - **Apps**: Add critical applications, such as:  
     - Bitdefender Endpoint Protection  
     - Microsoft Teams  
   - **Scripts**: Include PowerShell scripts for preparation tasks:  
     - Silent OneDrive Sync  
     - Taskbar Configuration  

7. **Assigments**:  
   - Ensure that **`Intune_Preperation_Users`** is assigned under **Assignments** to allow users to initiate preparation.

8. **Review and Create**:  
   - Verify all settings and assignments.  
   - Click **Create** to finalize the policy.

#### **Device Preparation Flow**

```plaintext
Device Enrollment --> Intune_Devices_Enrolled (Assigned Policy)
              |                              |
              |   OOBE: Apps, Scripts, Settings  |
              v                              v
        Device Ready --> Intune_Devices_Company (Post Policies)
```

**Note**: Device Preparation is best suited for environments requiring quick deployment with fewer configuration steps.

---

### **Option 2: Windows Autopilot Deployment Profile**

The **Windows Autopilot Deployment Profile** provides a fully customizable deployment experience and requires devices to be pre-registered in Windows Autopilot.

#### **Steps to Configure the Deployment Profile**

1. **Navigate to Microsoft Intune Admin Center**:  
   - Go to **Devices > Windows > Windows enrollment > Deployment Profiles**.

2. **Create the Deployment Profile**:  
   - Click **+ Create profile**.  
   - **Name**: Enter a descriptive name, such as **`Autopilot_Deployment`**.

3. **Configure Deployment Settings**:  
   - **Deployment mode**: Choose one of the following:  
     - **User-driven**: For user-initiated provisioning.  
     - **Self-deploying**: For kiosk or shared devices.  
     - **Pre-provisioned**: For IT-managed pre-setup.  
   - **Join type**: Select **Microsoft Entra joined** or **Hybrid Azure AD joined**.  
   - **User account type**: Choose **Standard User** or **Administrator**.

4. **Configure OOBE Settings**:  
   - **Language (Region)**: Set the default language and region.  
   - **Privacy settings**: Configure whether privacy options are shown during OOBE.  
   - **License Terms**: Suppress or display Microsoft Software License Terms.  

5. **Configure Device Naming Template**:  
   - **Apply Device Name Template**: Specify a naming convention, such as:  
     ```plaintext
     {Company Acronym}-%SERIAL%
     ```  
     > This will dynamically assign device names during deployment.  

6. **Assign the Deployment Profile**:  
   - Assign the profile to the **`Intune_Devices_Enrolled`** group.  

7. **Review and Create**:  
   - Review all settings and assignments.  
   - Click **Create** to finalize the profile.

#### **Deployment Profile Flow**

```plaintext
Device Registered in Autopilot --> Intune_Devices_Enrolled (Assigned Profile)
              |                              |
              |   OOBE: Apps, Naming, Settings  |
              v                              v
        Device Ready --> Intune_Devices_Company (Post Policies)
```

**Note**: Deployment Profiles offer greater flexibility for complex environments requiring extensive customization and pre-registration.

---

## 3. Group Structure and Membership

### **Dynamic Groups**
- See the [Dynamic Groups for Targeted Deployment Guide](GUIDE_Entra_Profile_Location_Based_Dynamic_Groups.md) for additional group conditions.

| **Group Name**               | **Dynamic Query**                                                    | **Purpose**                             |
|------------------------------|----------------------------------------------------------------------|-----------------------------------------|
| **Intune_Devices_Company**   | `(device.deviceOwnership -eq "Company") and (device.displayName -startsWith "{Company Acronym}-")` | This will be the base application & script association group, the `device.displayName -startsWith` is utalised to ensure it is appying to groups that have undergone inital configurations where device name is set |
| **Intune_Devices_Personal**  | `(device.deviceCategory -eq "Personal Device") or (device.deviceOwnership -eq "Personal")` | This is for monitoring & tracking purposes |
| **Intune_Devices_Windows11** | `(device.osVersion -startsWith "10.0.1")`                                                  | This is for monitoring & tracking purposes |
| **Intune_Devices_All**       | `(device.devicePhysicalIDs -any _ -contains "[ZTDID]")`                                    | This will allow any device that is Intuned joined to undergo Autopilot |
| **Intune_Devices_{OrderID}** | `(device.devicePhysicalIds -any (_ -eq "[OrderID]:{OrderID}"))`                            | This will allow specific devices to that are Intuned joined to undergo Autopilot |


### **Static Groups**
| **Group Name** | **Purpose** |
|---------------------------------------|----------------------------------------|
| **Intune_Preperation_Users** | Assigned to the Preparation Policy "Assignments", these are the users that will be allowed to undergo a preperation deployment |
| **Intune_Devices_Enrolled** | Assigned to the Deployment Profile "Assignments" or the Preperation Policy "Device group". |

#### Nested Membership:
- Add **`Intune_Devices_All`** or **`Intune_Devices_{OrderID}`** as members of **`Intune_Devices_Enrolled`** to ensure all devices are captured based on your needs.

---

## 4. Standard Device Configuration

- [Create a Local Administartor Account](Configure%20-%20Local%20Admin/GUIDE_Create_Local_Administrator.md)
- [Enable LAPS for password management](GUIDE_Intune_LAPS_Guide.md)
- [Configure WiFi](Configure%20-%20Wi-Fi/GUIDE_Configure_WiFi.md)
- [Configure Desktop Background](Configure%20-%20Background%20Image/GUIDE_Setup_Background_Images.md)
  > This is dependent on the `Software Custom - IntuneDependencies` package.
- [Configure Taskbar](Configure%20-%20Taskbar/GUIDE_Configure_Taskbar.md)
  > Deploy injunction with software.
- [Configure Sharepoint OneDrive AutoSync](Configure%20-%20OneDrive%20(silent%20sync)/GUIDE_Intune_OneDrive_Sync.md)
  > Recommended to deploy the bonus remediation script.

---

## 5. Deploying Applications (system)

- [Dynamic Groups for Targeted Deployment](GUIDE_Entra_Profile_Location_Based_Dynamic_Groups.md)  
   > **Use Case:** Office or Department-based application or printer deployment.

### General Deployables
```
   |-Software
   |---Adobe Unified (Acrobat & Reader)
   |---Bitdefender
   |---Citrix Workspace
   |---Google Chrome
   |---Slack
   |---Teams
```
> See `Software - TEMPLATE` for a base script to use/package when deploying software to Intune. It supports .msi & .exe files.

- **Microsoft Office**: Deploy via Intune Microsoft Store.

### Deployable Additionals
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

---

## 6. Deploying Applications (user)

When deplying applications, some will be per user, either by the requirements or by design. Often the software won't be available on first login, esspecially if the device exchanges from one user to another.

### Custom Loading Screen

You as an admin may not want the user to access the desktop while it is not prepared.

My custom solution to this is this custom [Loading Screen](Software%20Custom%20-%20LoadingScreen%20(per%20user)/ReadMe.md) which will run once for the user, locking out the desktop in a full screen window while disabling key presses for 1.5 hours (set by `Start-Sleep -Seconds 5400`) however `Ctrl + Shift + M` will also force close the  window / script.

```
   |-Software Custom
   |--- LoadingScreen (per user)
```

### User Deployables
```
   |-Software
   |---Asana (per user)
```

---

Further to come on device compliance, security & conditional access

If you need further clarification or assistance, feel free to ask! 🚀