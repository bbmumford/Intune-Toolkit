& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/Raphire/Win11Debloat/master/Get.ps1"))) -RemoveCommApps -RemoveDevApps -RemoveGamingApps -DisableDVR -ClearStartAllUsers -DisableTelemetry -DisableBing -DisableSuggestions -TaskbarAlignLeft-HideSearchTb -HideTaskview -HideChat -DisableWidgets -DisableCopilot -DisableRecall -HideGallery -Hide3dObjects -HideMusic -Silent
#Need to change to REGKEY detection
New-Item -Path "C:\IntuneDependencies\" -Name "Raphire-Debloat_Detection.txt" -ItemType "File"
