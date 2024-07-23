        ____      __                     _       ___           __                  
       /  _/___  / /___  ______  ___    | |     / (_)___  ____/ /___ _      _______
       / // __ \/ __/ / / / __ \/ _ \   | | /| / / / __ \/ __  / __ \ | /| / / ___/
     _/ // / / / /_/ /_/ / / / /  __/   | |/ |/ / / / / / /_/ / /_/ / |/ |/ (__  ) 
    /___/_/ /_/\__/\__,_/_/ /_/\___/    |__/|__/_/_/ /_/\__,_/\____/|__/|__/____/  
                                                                      
  
# Pre-Requisites
  # Enabling Temporary Access Password (TAP) in Microsoft Intune

  Temporary Access Password (TAP) allows users to gain temporary access to their devices when they are locked out, without requiring intervention from IT support. This guide outlines the steps to enable and configure TAP in Microsoft Intune.

  ## Steps to Enable TAP

  ### 1. **Open Microsoft Endpoint Manager Admin Center**

  1. Go to [Microsoft Endpoint Manager Admin Center](https://endpoint.microsoft.com/).
  2. Sign in with your admin credentials.

  ### 2. **Navigate to Device Enrollment**

  1. In the Microsoft Endpoint Manager Admin Center, go to `Devices` > `Enroll devices`.
  2. Click `Enrollment Program Tokens`.

  ### 3. **Create or Edit an Enrollment Program Token**

  1. If you don't already have an Enrollment Program Token, click `+ Create`.
  2. If you have an existing token, click on it to edit.

  ### 4. **Enable TAP**

  1. **Find and Configure TAP Settings**
    - Within the Enrollment Program Token settings, locate the `Temporary Access Password` section.
    - Enable TAP by toggling the switch to `On`.

  2. **Configure TAP Settings**
    - **Duration**: Set the duration for which the TAP will be valid.
    - **Password Complexity**: Define the complexity requirements for the TAP.
    - **Number of Attempts**: Specify the number of allowed attempts before a user must contact support.

  ### 5. **Save and Apply**

  1. Click `Save` to apply the TAP settings.
  2. Ensure that the updated token settings are applied to your devices.


# Enable Windows Diagnostic Data and Licensing Usage

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

4. **Review Configuration Settings**
   - Verify the settings as shown below:
      Enable features that require Windows diagnostic data in processor configuration = On 
      Windows license verification for Features, including the Windows 11 Upgrade Readiness report and Proactive remediations in Endpoint analytics = On

  
  Create an AutoEnrolment Deployment Security Group
  https://docs.42gears.com/suremdm/docs/SureMDM/UploadDeviceIDsConfigureandAutoP.html
  https://www.petervanderwoude.nl/post/automatically-assign-windows-autopilot-deployment-profile-to-windows-autopilot-devices/


  BONUS

  Enroll devices from Entra (non MDM managed devices)
  https://call4cloud.nl/2020/05/intune-auto-mdm-enrollment-for-devices-already-azure-ad-joined/