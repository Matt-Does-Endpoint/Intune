#Load Default User Profile for modification
reg load HKU\DEFAULT_USER C:\Users\Default\NTUSER.DAT

#registry settings for all users modified in the default profile.
#Set policy to sync edge
reg.exe add "HKU\DEFAULT_USER\Software\Policies\Microsoft\Edge" /v ForceSync /t REG_DWORD /d 1 /f | Out-Host
#Sets Dark Mode as default for the system
reg.exe add "HKU\DEFAULT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v SystemUsesLightTheme /t REG_DWORD /d 0 /f | Out-Host
#sets dark as default for apps/system windows
reg.exe add "HKU\DEFAULT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme /t REG_DWORD /d 0 /f | Out-Host
#Sets desktop icon size to small and restarts explorer. 
reg.exe add "HKU\DEFAULT_USER\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop" /v IconSize /t REG_DWORD /d 32 /f | Out-Host
#Sets onedrive to skip first deletion notification, as UE-V will prompt this until the user ignores it.
reg.exe add "HKU\DEFAULT_USER\SOFTWARE\Microsoft\OneDrive" /v FirstDeleteDialogsShown /t REG_DWORD /d 1 /f | Out-Host
#allows apps to use location
reg.exe add "HKU\DEFAULT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" /v Value /t REG_SZ /d Allow /f | Out-Host
#stops the start menu from popping up on login
reg.exe add "HKU\DEFAULT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v StartShownOnUpgrade /t REG_DWORD /d 1 /f | Out-Host
#blocks spam on the lock screen
reg.exe add "HKU\DEFAULT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RotatingLockScreenOverlayEnabled /t REG_DWORD /d 0 /f | Out-Host
reg.exe add "HKU\DEFAULT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338387Enabled /t REG_DWORD /d 0 /f | Out-Host
#remove windows Tips
reg.exe add "HKU\DEFAULT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v subscribedContent-338389Enabled /t REG_DWORD /d 0 /f | Out-Host
#remove windows Welcome
reg.exe add "HKU\DEFAULT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-310093Enabled /t REG_DWORD /d 0 /f | Out-Host
#remove "get even more out of windows"
reg.exe add "HKU\DEFAULT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" /v ScoobeSystemSettingEnabled /t REG_DWORD /d 0 /f | Out-Host
#remove chat from windows taskbar
reg.exe add "HKU\DEFAULT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarMn /t REG_DWORD /d 0 /f | Out-Host
#remove task view from taskbar
reg.exe add "HKU\DEFAULT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v  ShowTaskViewButton /t REG_DWORD /d 0 /f | Out-Host
#remove windows widgets
reg.exe add "HKU\DEFAULT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDA /t REG_DWORD /d 0 /f | Out-Host
#Hide "Learn more about this picture" from the desktop
reg.exe add "HKU\DEFAULT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{2cc5ca98-6485-489a-920e-b3e88a6ccce3}" /t REG_DWORD /d 1 /f | Out-Host


#Unload Default User Profile
reg unload HKU\DEFAULT_USER
