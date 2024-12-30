# Execute the debloat script
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/Raphire/Win11Debloat/master/Get.ps1"))) -RemoveCommApps -RemoveDevApps -RemoveGamingApps -DisableDVR -ClearStartAllUsers -DisableTelemetry -DisableBing -DisableSuggestions -TaskbarAlignLeft -HideSearchTb -HideTaskview -ShowHiddenFolders -HideChat -DisableWidgets -DisableCopilot -DisableRecall -HideGallery -Hide3dObjects -HideMusic -Silent
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/andrew-s-taylor/public/refs/heads/main/De-Bloat/RemoveBloat.ps1")))

# Create the registry key and set a DWORD value to indicate completion
New-Item -Path "HKLM:\Software\IntuneDependencies" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\Software\IntuneDependencies" -Name "RaphireDebloatCompleted" -Value $true -Force
