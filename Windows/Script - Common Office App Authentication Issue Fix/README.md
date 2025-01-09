# Intune Remediation: Fix Modern Authentication Issues in Outlook

This guide explains how to deploy the `FixADAL` scripts via Microsoft Intune to resolve issues related to Modern Authentication in Microsoft Outlook, such as the "Outlook needs password but dialog box disappears" problem.

---

## Issue Description

### Common Symptoms:
1. **Outlook repeatedly prompts for a password but the dialog box disappears.**
2. **Authentication issues with Office 2016 applications.**
3. **Inconsistent or failed sign-ins due to Modern Authentication configuration.**

---

## Solution Overview

The issue is resolved by disabling Modern Authentication using registry modifications:
- Disable `EnableADAL` by setting its value to `0`.
- Enable `DisableADALatopWAMOverride` by setting its value to `1`.

Scripts (`FixADAL_Detection.ps1` and `FixADAL_Remediation.ps1`) will be deployed through Intune as a remediation policy to detect and fix the issue.

---

## Deployment Steps

### 1. Prerequisites

- **Administrative Access**: Ensure you have access to the Intune Admin Center.
- **Script Files**: Both `FixADAL_Detection.ps1` and `FixADAL_Remediation.ps1` must be stored in the same directory as this guide.

---

### 2. Upload the Scripts to Intune

1. **Open the Microsoft Endpoint Manager Admin Center**:
   - Navigate to **Devices > Scripts**.

2. **Add a New Remediation Policy**:
   - Go to **Proactive Remediations** under **Reports > Endpoint Analytics**.
   - Click **Create Script Package**.

3. **Provide the Following Details**:
   - **Name**: `Fix Modern Authentication - Outlook`
   - **Detection Script**: Upload `FixADAL_Detection.ps1`.
   - **Remediation Script**: Upload `FixADAL_Remediation.ps1`.

4. **Assign the Policy**:
   - Target the affected devices or users.
   - Ensure the remediation script is run in the **user context** to apply settings to `HKEY_CURRENT_USER`.

---

### 3. Validate Deployment

1. Check the **Proactive Remediations** results in Intune to confirm the detection and remediation process.
2. Restart Outlook on affected devices.
3. Confirm that the password dialog box no longer disappears unexpectedly.

---

## Notes

- The scripts are designed to operate under the **user context** since they modify `HKEY_CURRENT_USER` registry keys.
- Backing up the registry before deployment is recommended.
- The scripts referenced (`FixADAL_Detection.ps1` and `FixADAL_Remediation.ps1`) are stored in the same folder as this guide.

For further assistance, consult your IT administrator or Microsoft documentation.
