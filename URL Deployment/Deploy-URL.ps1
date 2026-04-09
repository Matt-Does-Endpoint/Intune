$ScriptDirectory = "C:\ProgramData\Scripts"
$Scripts = Test-Path $ScriptDirectory
If($Scripts -eq $False){New-Item -Path C:\ProgramData\Scripts -ItemType Directory}

Copy-Item .\Application.ico -Destination $ScriptDirectory


#create URL that's modifiable
$WshShell = New-Object -comObject WScript.Shell
$targetPath = "https://URLNAME"
$iconLocation = "C:\ProgramData\Scripts\Application.ico"
$iconFile = "IconFile=" + $iconLocation
$path = "C:\Users\Public\Desktop\Application.url"
$Shortcut = $WshShell.CreateShortcut($path)
$Shortcut.TargetPath = $targetPath
$Shortcut.Save()

Add-Content $path "HotKey=0"
Add-Content $path "$iconfile"
Add-Content $path "IconIndex=0"
