
> [!CAUTION] 
> DO NOT USE. 
> This Script is an active work in progress to address as many security score items as possible without the necessity of a domain controller.

Explanation
1. Windows Defender: Ensures that Windows Defender Antivirus is enabled and set to start automatically.
2. Firewall: Enables the Windows Defender Firewall for all profiles.
3. Password Policy: Configures the password policies, such as length and maximum age.
4. BitLocker: Enables BitLocker encryption on the operating system drive (you should replace "YourPasswordHere" with a strong password).
5. Windows Update: Configures Windows Update to automatically download updates and notify for installation.
6. SMBv1: Disables SMBv1, which is a known vulnerability.
7. UAC: Enables User Account Control.
8. Audit Policy: Configures auditing for logon events.
9. Disable Services: Stops and disables unnecessary services to minimize attack surfaces.