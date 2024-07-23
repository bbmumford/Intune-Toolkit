# Configure Wi-Fi in Intune

To configure Wi-Fi settings in Intune, follow these steps:

1. Log in to the Intune portal.
2. Navigate to **Devices** > **Configuration profiles**.
3. Click on **Create profile**.
4. Select **Wi-Fi** as the profile type.
5. Provide a **Name** for the profile.
6. Under **Connection settings**, enter the following details:
    - **SSID**: Enter the name of the Wi-Fi network.
    - **Security type**: Choose the appropriate security type (e.g., WPA2-Enterprise).
    - **Encryption type**: Select the encryption type used by the Wi-Fi network.
    - **Authentication method**: Choose the authentication method (e.g., EAP-TLS).
    - **Identity**: Enter the user identity for authentication.
    - **Password**: Provide the password for the Wi-Fi network.
7. Configure any additional settings as required, such as proxy settings or certificate requirements.
8. Click on **Next** to proceed.
9. Assign the profile to the desired **Device groups** or **Users**.
10. Review the settings and click on **Create** to save the profile.
11. The Wi-Fi configuration will now be applied to the devices or users specified in the assignment.
