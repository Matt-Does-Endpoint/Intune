#create .LNK for exe.
$Shell = New-Object -ComObject ("WScript.Shell")
$ShortCut = $Shell.CreateShortcut("C:\Users\Public\Desktop\Application.url")
$ShortCut.TargetPath="https://URL.com"
$ShortCut.Target="https://URL.com"
$ShortCut.IconLocation = "C:\ProgramData\Scripts\Application.ico, 0";
$ShortCut.Save()

Add-Content $path "$iconfile"
Add-Content $path "IconIndex=0"
