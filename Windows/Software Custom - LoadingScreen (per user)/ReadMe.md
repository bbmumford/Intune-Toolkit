#### Install command
 `%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -command .\LoadingScreen.ps1`

Install as **User**

#### Uninstall command
`cmd.exe rd "%localappdata%\IntuneDependencies\DeviceConfigurationComplete.txt" /s /q`

#### Detection Rule
File Exists `%localappdata%\IntuneDependencies\DeviceConfigurationComplete.txt`