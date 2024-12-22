# Creating a Dynamic Group with Azure Active Directory

This guide provides step-by-step instructions on how to create a dynamic group in Azure Active Directory (Entra) using a membership rule based on user attributes.

## Prerequisites

Before you start, ensure you have the following:
- Admin access to Azure Active Directory.

## Steps

### Step 1: Access Azure Active Directory

1. **Log in to the Azure Portal**
   - Go to [Azure Portal](https://portal.azure.com/).
   - Sign in with your admin credentials.

2. **Navigate to Azure Active Directory**
   - In the left-hand sidebar, click on `Azure Active Directory`.

### Step 2: Create a New Dynamic Group

1. **Navigate to Groups**
   - In the Azure Active Directory pane, click on `Groups`.

2. **Create a New Group**
   - Click `+ New group`.
   - In the `Group` pane, select `Security` as the group type.
   - Set `Membership type` to `Dynamic User`.

3. **Enter Group Details**
   - Enter a `Group name` and `Group description`.

### Step 3: Define the Membership Rule

#### Device Dynamic Group Conditions

| **Property**                   | **Operator**            | **Example Value**         |
|--------------------------------|-------------------------|---------------------------|
| device.deviceId                | Equals / Not Equals     | `12345678-abcd-efgh-ijkl` |
| device.displayName             | Contains / Starts With / Equals | `DeviceName01`         |
| device.enrollmentProfileName   | Equals / Not Equals     | `CorporateProfile`        |
| device.isCompliant             | Equals / Not Equals     | `True` / `False`          |
| device.isManaged               | Equals / Not Equals     | `True` / `False`          |
| device.operatingSystem         | Equals / Not Equals     | `Windows` / `iOS`         |
| device.operatingSystemVersion  | Greater Than / Less Than / Equals | `10.0.19042` |
| device.physicalIds             | Contains                | `[OrderID]:12345`         |
| device.trustType               | Equals / Not Equals     | `Azure AD joined`         |
| device.managementType          | Equals / Not Equals     | `MDM` / `EAS`             |
| device.deviceOwnership         | Equals / Not Equals     | `Company` / `Personal`    |
| device.deviceCategory          | Equals / Not Equals     | `HR Devices`              |
| device.deviceModel             | Equals / Not Equals     | `Surface Pro 7`           |
| device.deviceManufacturer      | Equals / Not Equals     | `Microsoft`               |
| device.deviceOSType            | Equals / Not Equals     | `Windows` / `iOS`         |
| device.deviceOSVersion         | Greater Than / Less Than / Equals | `10.0.19042` |
| device.profileType             | Equals / Not Equals     | `Corporate` / `Personal`  |
| device.systemLabels            | Contains                | `["HighSecurity"]`        |
| device.isRooted                | Equals / Not Equals     | `True` / `False`          |
| device.managementAgent         | Equals / Not Equals     | `MDM` / `EAS`             |
| device.deviceManagementAppId   | Equals / Not Equals     | `0000000a-0000-0000-c000-000000000000` (Intune) |

#### User Dynamic Group Conditions

| **Property**                   | **Operator**            | **Example Value**         |
|--------------------------------|-------------------------|---------------------------|
| user.displayName               | Contains / Starts With / Equals | `John Doe`            |
| user.department                | Equals / Not Equals     | `HR` / `Engineering`     |
| user.jobTitle                  | Equals / Not Equals     | `Manager`                |
| user.mail                      | Contains / Starts With / Ends With | `@example.com`    |
| user.userPrincipalName         | Contains / Starts With / Ends With | `johndoe`          |
| user.accountEnabled            | Equals / Not Equals     | `True` / `False`         |
| user.assignedPlans             | Contains                | `Microsoft 365 E3`       |
| user.usageLocation             | Equals / Not Equals     | `US` / `CA`              |
| user.companyName               | Equals / Not Equals     | `Contoso Ltd`            |
| user.onPremisesSyncEnabled     | Equals / Not Equals     | `True` / `False`         |
| user.city                      | Equals / Not Equals     | `Seattle`                |
| user.country                   | Equals / Not Equals     | `United States`          |
| user.physicalDeliveryOfficeName| Equals / Not Equals     | `Building 1`             |
| user.postalCode                | Equals / Not Equals     | `98052`                  |
| user.preferredLanguage         | Equals / Not Equals     | `en-US`                  |
| user.state                     | Equals / Not Equals     | `WA`                     |
| user.streetAddress             | Equals / Not Equals     | `1 Microsoft Way`        |
| user.surname                   | Equals / Not Equals     | `Doe`                    |
| user.telephoneNumber           | Equals / Not Equals     | `+1 425 555 0100`        |
| user.otherMails                | Contains                | `alias@example.com`      |
| user.proxyAddresses            | Contains                | `SMTP:alias@example.com` |
| user.employeeId                | Equals / Not Equals     | `123456`                 |
| user.employeeHireDate          | Equals / Not Equals     | `2024-01-15T00:00:00Z`   |
| user.facsimileTelephoneNumber  | Equals / Not Equals     | `+1 425 555 0101`        |
| user.givenName                 | Equals / Not Equals     | `John`                   |
| user.mailNickName              | Equals / Not Equals     | `johnd`                  |
| user.mobile                    | Equals / Not Equals     | `+1 425 555 0102`        |
| user.onPremisesDistinguishedName | Equals / Not Equals  | `CN=John Doe,OU=Users,DC=example,DC=com` |
| user.onPremisesSecurityIdentifier | Equals / Not Equals | `S-1-5-21-3623811015-3361044348-30300820-1013` |
| user.sipProxyAddress           | Equals / Not Equals     | `sip:johndoe@example.com`|
| user.userType                  | Equals / Not Equals     | `Member` / `Guest`       |


#### Setting Rules

1. **Set Up Membership Rule**
   - In the `Dynamic user` pane, scroll down to `Dynamic membership rules`.
   - Click `Add dynamic query`.

2. **Enter Membership Rule Syntax**
   - In the `Edit membership rule` pane, enter the following syntax to filter users based on the `physicalDeliveryOfficeName` attribute:

     ```plaintext
     (user.physicalDeliveryOfficeName -eq "LocationHere")
     ```

   - Replace `"LocationHere"` with the actual office location you want to use for filtering. This is pulled from Entra profile details.

3. **Validate and Save Rule**
   - Click `Validate` to check the rule syntax.
   - If validation is successful, click `Save` to apply the membership rule.

### Step 4: Review and Create Group

1. **Review Group Settings**
   - Review the group details and the dynamic membership rule you’ve configured.

2. **Create the Group**
   - Click `Create` to finalize and create the dynamic group.

## Conclusion

By following these steps, you have successfully created a dynamic group in Azure Active Directory with a membership rule based on the `physicalDeliveryOfficeName` attribute. This allows you to automatically include users whose office location matches the specified value.

For more detailed information, refer to the official [Microsoft documentation on dynamic membership rules](https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/groups-dynamic-membership) and [Azure Active Directory Groups](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/groups-create-azure-portal).
