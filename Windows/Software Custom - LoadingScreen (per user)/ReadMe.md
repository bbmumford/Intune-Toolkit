Install command
 %SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -command .\LoadingScreen.ps1
Uninstall command
cmd.exe rd "%localappdata%\IntuneDependencies\DeviceConfigurationComplete.txt" /s /q

Install behavior
User

Rules format
Manually configure detection rules
Detection rules
File %localappdata%\IntuneDependencies\DeviceConfigurationComplete.txt