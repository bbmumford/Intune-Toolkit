echo OFF
echo Gathering AutoPilot Hash

set script=%~dp0Hardware_HASH_Get.ps1
set TodaysDate=%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%
set CSV=%~dp0%TodaysDate%.csv

REM run script and append
PowerShell -NoProfile -ExecutionPolicy Unrestricted -Command %script% -OutputFile %CSV% -append
echo CSV Created, now attempting to sumbit online.
echo Press ENTER when prompted, wait, the enter your Intune Administrator credentials.
echo .

REM Attempt online registration
PowerShell -NoProfile -ExecutionPolicy Unrestricted -Command %script% -Online

REM Get Serial
for /f "tokens=2 delims==" %%J in ('wmic bios get serialnumber /value') do set serial=%%J
echo .
echo Got hash for %serial%

pause
