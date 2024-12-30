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
   - Go to [Microsoft Endpoint Manager Admin Center TAP Configuration](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ConfigureAuthMethodsBlade/authMethod~/%7B%22%40odata.type%22%3A%22%23microsoft.graph.temporaryAccessPassAuthenticationMethodConfiguration%22%2C%22id%22%3A%22TemporaryAccessPass%22%2C%22state%22%3A%22enabled%22%2C%22defaultLifetimeInMinutes%22%3A60%2C%22defaultLength%22%3A8%2C%22minimumLifetimeInMinutes%22%3A60%2C%22maximumLifetimeInMinutes%22%3A1440%2C%22isUsableOnce%22%3Afalse%2C%22excludeTargets%22%3A%5B%5D%2C%22includeTargets%40odata.context%22%3A%22https%3A%2F%2Fgraph.microsoft.com%2Fbeta%2F%24metadata%23policies%2FauthenticationMethodsPolicy%2FauthenticationMethodConfigurations('TemporaryAccessPass')%2Fmicrosoft.graph.temporaryAccessPassAuthenticationMethodConfiguration%2FincludeTargets%22%2C%22includeTargets%22%3A%5B%7B%22targetType%22%3A%22group%22%2C%22id%22%3A%22all_users%22%2C%22isRegistrationRequired%22%3Afalse%7D%5D%2C%22enabled%22%3Atrue%2C%22target%22%3A%22All%20users%22%2C%22isAllUsers%22%3Atrue%2C%22voiceDisabled%22%3Afalse%7D/canModify~/true/voiceDisabled~/false/userMemberIds~/%5B%2262e90394-69f5-4237-9190-012177145e10%22%2C%22cf1c38e5-3621-4004-a7cb-879624dced7c%22%2C%22e8cef6f1-e4bd-4ea8-bc07-4b8d950f4477%22%2C%22d37c8bed-0711-4417-ba38-b4abe66ce4c2%22%2C%2211451d60-acb2-45eb-a7d6-43d0f0125c13%22%2C%22fe930be7-5e62-47db-91af-98c3a49a38b1%22%2C%223a2c62db-5318-420d-8d74-23affee5d9d5%22%2C%22644ef478-e28f-4e28-b9dc-3fdde9aa0b1f%22%2C%22f28a1f50-f6e7-4571-818b-6a12f2af6b6c%22%2C%227698a772-787b-4ac8-901f-60d6b08affd2%22%2C%2227460883-1df1-4691-b032-3b79643e5e63%22%2C%22729827e3-9c14-49f7-bb1b-9608f156bbb8%22%2C%2269091246-20e8-4a56-aa4d-066075b2a7a8%22%2C%2229232cdf-9323-42fd-ade2-1d097af3e4de%22%2C%22966707d0-3269-4727-9be2-8c3a10f19b9d%22%2C%22f023fd81-a637-4b56-95fd-791ac0226033%22%2C%2238a96431-2bdf-4b4c-8b6e-5d3d8abac1a4%22%2C%22f2ef992c-3afb-46b9-b7cf-a126ee74c451%22%2C%22194ae4cb-b126-40b2-bd5b-6091b380977d%22%2C%229b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3%22%2C%220526716b-113d-4c15-b2c8-68e3c22b9f80%22%2C%2245d8d3c5-c802-45c6-b32a-1d70b5e1e86e%22%2C%223071c0f1-6fc7-4ecc-9310-f7edf51cacc3%22%2C%22277e0b86-72b0-4637-8983-403a208697c5%22%2C%224928b003-c5df-49e4-9579-7837d9c9dcb0%22%2C%22317cccf5-18f0-4df1-a817-45b474bbc48f%22%2C%22284cb16e-7d17-4c0a-b3d3-36cfbce45687%22%2C%229251d5eb-da94-42ba-aa98-6beea63b9412%22%2C%22a3ab4ef3-3360-433f-9314-74bfb6268dd7%22%2C%22ee0a0d0b-db58-46e7-83f3-dc7ed324443f%22%2C%2276b62f99-762e-4ccb-8d59-e7e2aaeb5999%22%2C%2238ef97af-10c5-449d-8334-e0b4dcbd65e9%22%2C%226581ad2d-17eb-44e7-9d8c-e11212c851a3%22%2C%228ddddaa8-2fe3-465a-8fba-46ab22b9470d%22%2C%222ae46602-de4c-4e15-b834-d0442b158d5f%22%2C%22bf13fcd8-7a7c-4cf2-a065-3fe942a66a70%22%2C%229e787f55-1ab2-4b8c-ac96-b0f5ad24ce32%22%2C%22be124073-f2ce-44e0-988e-2985c80ec044%22%2C%229725bbfb-8ed9-4acc-87fc-2fa5bea0953e%22%2C%22f6e1bc92-1fc8-4251-9605-edd125cafb6a%22%2C%22881a5f2a-62d1-4379-a34d-1ee8c8424b5a%22%5D/userId/fdad6e43-962a-4c6f-9919-a532ed6708f7/isCiamTenant~/false/isCiamTrialTenant~/false).  
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
| **Intune_Devices_All**       | `(device.deviceId -ne null)`                                    | This will all tenant devices, personal & corporate |
| **Intune_Devices_Enrolled**       | `(device.devicePhysicalIDs -any _ -contains "[ZTDID]")`                                    | This will allow any device that is Intuned Autopilot registed |
| **Intune_Devices_{OrderID}** | `(device.devicePhysicalIds -any (_ -eq "[OrderID]:{OrderID}"))`                            | This will allow specific devices to that are Intuned joined to undergo Autopilot |


### **Static Groups**
| **Group Name** | **Purpose** |
|---------------------------------------|----------------------------------------|
| **Intune_Preperation_Users** | Assigned to the Preparation Policy "Assignments", these are the users that will be allowed to undergo a preperation deployment |
| **Intune_Enrollment_Users** | Used for limited cases where you want to allow users to enroll devices directly, to be also assigned to the Preparation Policy "Assignments", these are the users that will be allowed to undergo a preperation deployment |
| **Intune_Enrollment_Admins** | Used to restrict who on a ongoing basis can enroll devices |
| **Intune_Administrators** | Used to mange intune features as onlt adding the Intune Administrator role does not give complete mangement access |

#### Nested Membership:
- Add **`Intune_Devices_All`** or **`Intune_Devices_{OrderID}`** as members of **`Intune_Devices_Enrolled`** to ensure all devices are captured based on your needs.

- ~~Add **`Intune_Administrators`** as members of **`Intune_Enrollment_Admins`** to ensure that the Intune Administrator Role may enrol devices.~~

---

## 4. Configuring Intune Roles & Restricting Device Enrollment

https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/RolesLandingMenuBlade/~/roles




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

- **Recommended Base System Deployable**
```
   |-Software Custom
   |---DesktopInfo (display device name on desktop)
   |---ExplorerPatcher (adjust explorer to appear more user-friendly)
   |---IntuneDependencies (deploy local application or script dependencies)
```
- **Recommended Base System Remediation Scripts**
```
   |-Script
   |---Clear-TeamsCache
   |---Configure-ExplorerPatcher
   |---Device-Auto-Syncer
   |---Device-Restore-Points
   |-Configure
   |---OneDrive (silent sync)
```

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
> See `Software - TEMPLATE` for a base script to use/package when deploying software to Intune. It supports .msi & .exe files.

---

Further to come on device compliance, security & conditional access

If you need further clarification or assistance, feel free to ask! 🚀