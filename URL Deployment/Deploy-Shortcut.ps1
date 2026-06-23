#Custom Shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\Self Service.lnk")
$Shortcut.WorkingDirectory = "C:\ProgramData\Scripts"
$Shortcut.TargetPath = "C:\ProgramData\Scripts\Self Service.exe"
#$Shortcut.WindowStyle = 7
$shortcut.IconLocation="$Env:ProgramData\Scripts\company.ico"
$Shortcut.Save()
