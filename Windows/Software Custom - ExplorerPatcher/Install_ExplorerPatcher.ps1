# # Written on 18/7/2024
# BAMITS - William Buckley
#
## Created to Wrap up the Explorer patcher app, With an Explorer restart at the end
$ErrorActionPreference= 'silentlycontinue'

ep_setup.exe

$processid = (Get-Process -Name explorer).Id

if ($processid -ne $null) {
    # Explorer Running
    exit 0
} else {
    # Explorer Not Running
    taskkill /f /im explorer.exe
    start explorer.exe
    exit 0
}