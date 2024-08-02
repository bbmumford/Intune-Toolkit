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
