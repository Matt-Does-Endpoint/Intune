# Variables
$Target = "$env:ProgramData\Scripts"
$Script = "NameOfScript.ps1"

# If local path for script doesn't exist, create it
If (!(Test-Path $Target)) { New-Item -Path $Target -Type Directory -Force }

#Create the PS1 File
New-Item "C:\ProgramData\Scripts\NameOfScript.ps1" -ItemType File -Force

#Write the Code into the PS1
Set-Content -PassThru "C:\ProgramData\Scripts\NameOfScript.ps1" 'InsertCodeForScriptBetweenThese
LittleSingleQuotes'



# Create the scheduled task to run the script at logon
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-ExecutionPolicy Bypass -NonInteractive -WindowStyle Hidden -File $Target\$Script"
$trigger =  New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -Hidden -DontStopIfGoingOnBatteries -Compatibility Win8
$principal = New-ScheduledTaskPrincipal -GroupId "NT AUTHORITY\SYSTEM"
$task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -Principal $principal
Register-ScheduledTask -InputObject $task -TaskName "TaskName" -Force

#unregsiter a task
Stop-ScheduledTask -TaskName "TaskName"

Unregister-ScheduledTask -TaskName "TaskName" -Confirm:$false -ErrorAction SilentlyContinue

