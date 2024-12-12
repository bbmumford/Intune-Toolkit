        ____      __                      __    _                 
       /  _/___  / /___  ______  ___     / /   (_)___  __  ___  __
       / // __ \/ __/ / / / __ \/ _ \   / /   / / __ \/ / / / |/_/
     _/ // / / / /_/ /_/ / / / /  __/  / /___/ / / / / /_/ />  <  
    /___/_/ /_/\__/\__,_/_/ /_/\___/  /_____/_/_/ /_/\__,_/_/|_|  

                                     
# Start Managing Your Linux with Intune (Desktop GUI Required)

This guide will help you start managing your Linux devices using Microsoft Intune. Follow these steps to configure and deploy Intune management for Linux systems.

## Prerequisites

- **Microsoft Intune subscription.**
- **Linux devices running supported distributions.**
- **Access to Microsoft Endpoint Manager Admin Center.**

## Steps to Manage Linux Devices with Intune

### 1. **Open Microsoft Endpoint Manager Admin Center**

1. Go to [Microsoft Endpoint Manager Admin Center](https://endpoint.microsoft.com/).
2. Sign in with your admin credentials.

### 2. **Configure Intune for Linux Management**

1. **Navigate to Device Enrollment**
   - In the Microsoft Endpoint Manager Admin Center, go to `Devices` > `Enroll devices`.
   
2. **Set Up Linux Enrollment**
   - Under `Enroll devices`, find and click on `Linux`.
   - Follow the prompts to set up enrollment for Linux devices. This setup will include generating a device enrollment profile.

### 3. **Download and Install the Intune Enrollment Agent**

1. **Download the Enrollment Agent**
   - Go to the `Enrollment` section for Linux devices and download the Intune Enrollment Agent package.

2. **Install the Enrollment Agent on Linux Devices**
   - Transfer the downloaded package to your Linux devices.
   - Install the package using the appropriate package manager for your distribution (e.g., `apt`, `yum`, `zypper`).

   ```bash
   sudo dpkg -i intune-enrollment-agent.deb
    ```

### 4. **Enroll Linux Devices**

1. **Start the Enrollment Process**
   - On your Linux device, run the Intune Enrollment Agent to initiate the enrollment.
   - Follow the prompts to authenticate and register the device with Intune.

2. **Verify Enrollment**
   - After completing the enrollment process, check the Microsoft Endpoint Manager Admin Center to ensure the device appears in the list of managed devices.

### 5. **Create and Assign Configuration Profiles**

1. **Navigate to Configuration Profiles**
   - In the Microsoft Endpoint Manager Admin Center, go to `Devices` > `Configuration profiles`.
   - Click `+ Create profile`.

2. **Create a New Profile for Linux**
   - Choose `Linux` as the platform.
   - Configure the profile settings according to your needs (e.g., security policies, network configurations).

3. **Assign the Profile**
   - Click `Assignments`.
   - Select the groups or individual devices to which the profile should be applied.

### 6. **Monitor and Manage Linux Devices**

1. **Monitor Device Compliance**
   - Go to `Devices` > `Monitor` in the Microsoft Endpoint Manager Admin Center to review compliance status and other reports.

2. **Manage Device Settings**
   - Adjust configurations and apply updates as needed from the Microsoft Endpoint Manager Admin Center.
