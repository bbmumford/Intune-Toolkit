# Configuring OneDrive Team Site Library Sync and Proactive Remediation

This guide will walk you through setting up a Configuration Profile in Microsoft Intune to automatically sync OneDrive team site libraries and configure Proactive Remediation to manage registry settings for sync delays.

## Before You Begin

Before setting up your Configuration Profile in Intune, gather the SharePoint document library ID(s). For this example, we’ll use the Sales and Marketing departments' library. Follow these steps:

1. **Browse to the SharePoint Library**
   - Navigate to the SharePoint document library you want to sync.

2. **Get the Library ID**
   - Click `Sync`.
   - A window will appear; ignore any prompts to open OneDrive.
   - Click `Copy library ID` and keep this value handy.

   **IMPORTANT**: The copied library ID must be converted from Unicode to ASCII. Open PowerShell and use the following command (replace `"Copied String"` with your copied library ID):

   ```powershell
   [uri]::UnescapeDataString("Copied String")
   ```
# Creating the Configuration Profile

## Open Microsoft Endpoint Manager Admin Center

1. Go to [Microsoft Endpoint Manager Admin Center](https://endpoint.microsoft.com/).
2. Sign in with your admin credentials.

## Navigate to Configuration Profiles

1. Click `Devices` > `Configuration profiles`.
2. Click `+ Create profile`.

## Create a New Profile

1. Choose `Windows 10 and later` as the platform.
2. Select `Templates` and then `OneDrive`.
3. Enter a name and description for your profile.

## Configure OneDrive Settings

1. **Select "Configure team site libraries to sync automatically"**:
   - Enable this setting.
   - Enter a name for the library for easy identification.
   - Paste the ASCII-converted library ID from earlier.
   - Add a description if necessary.

2. **Require users to confirm large delete operations**:
   - This setting is not required but recommended to prevent accidental data deletion.

3. **Convert synced team site files to online-only files**:
   - This setting is also recommended but not required.
   - It extends Files-On-Demand technology to synced libraries.

## Deploy the Configuration Profile

1. Assign the profile to your test users before deploying it to production.


# Bonus
**Create a Proactive Remediation Profile (Optional)**

To reduce the 8-hour delay for end-users to see their administratively assigned libraries via the OneDrive sync client, use Proactive Remediations. This will ensure that the necessary registry key is set or verified on a recurring basis.

1. **Navigate to Proactive Remediations**
   - Go to `Reports` > `Endpoint Analytics` > `Proactive Remediations`.
   - Click `+ Create Script Package`.

2. **Name and Describe the Script Package**
   - Enter an appropriate name and description for the script package.

3. **Upload the Detection Script**
   - File in repo [Here](/Windows/Configure%20-%20OneDrive%20(silent%20sync)/DisableSyncDelay_Detection.ps1)

4. **Upload the Remediation Script**
   - File in repo [Here](/Windows/Configure%20-%20OneDrive%20(silent%20sync)/DisableSyncDelay_Remediation.ps1)


5. **Configure Script Settings**
   - Set `Run this script using the logged-on credentials` to `Yes`.
   - Set `Run script in 64-bit PowerShell` to `Yes`.

6. **Set a Schedule**
   - Configure the script to run on a recurring schedule (e.g., every 1 hour).
   - Deploy the script package to the same users or devices as your Configuration Profile.
