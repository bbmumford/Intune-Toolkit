To set the desktop and lock screen backgrounds in Intune, follow these steps:

1. Open the Intune portal and sign in with your credentials.
2. Navigate to "Devices" and select "Configuration profiles".
3. Click on "Create profile" and choose "Windows 10 and later" as the platform.
4. Give the profile a name and select "Device restrictions" as the profile type.
5. Under "Settings", click on "Personalization".
6. In the "Desktop" section, click on "Add" and select "Image".
7. Specify the path to the desktop wallpaper file by entering `"C:\IntuneDependencies\Desktop_Wallpaper.png"`.
8. Configure any additional settings for the desktop background, such as the fit, fill, or stretch options.
9. In the "Lock screen" section, repeat steps 6-8 to set the lock screen background.
10. Once you have configured the desired settings, click on "OK" to save the profile.
11. Assign the profile to the appropriate devices or groups by clicking on "Assignments".
12. Review the assignments and click on "Save" to apply the profile to the selected devices.

> [!IMPORTANT]
> Please note that the specified desktop wallpaper file should be accessible to the devices being managed by Intune. 
> Ensure that the file is stored in a location that can be accessed by the devices.
> See `Software Custom - IntuneDependecies` for a method in which to get the file on the machine.