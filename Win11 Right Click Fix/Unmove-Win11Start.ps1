$osVersion = (Get-ComputerInfo | Select-Object -expand OsName)

if ($osVersion -match "10")
{
    Write-Host "Windows 10"
    exit 0
}elseif ($osVersion -match "11")
{
#Moves Start menu to the left
#variables for the HKCU key you want to change for all users
$RegPath = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$RegName = "TaskbarAl"
$RegValue = 1
#SIDS for all users
$UserSIDs = Get-ChildItem -Path 'REGISTRY::\HKEY_USERS' | Where-Object { $_.Name -notlike '*Classes' } | ForEach-Object { $_.PSChildName }

#check each user found in SIDs for presence of key you want to add, and adds if its missing.
ForEach ($SID in $UserSIDs) {
    $RegUserPath = "REGISTRY::\HKEY_USERS\$SID\$RegPath"
    if (Test-Path "$RegUserPath") {
        $RegUserValue = (Get-ItemProperty -Path $RegUserPath -Name $RegName -ErrorAction SilentlyContinue)."$RegName"
        if ($RegUserValue -eq $null -or $RegUserValue -ne $RegValue) {
            New-ItemProperty -Path $RegUserPath -Name $RegName -Value $RegValue -PropertyType DWORD -Force | Out-Null
            Write-Host "Created registry value $RegName for user with SID $SID."
        }
    }
}

$regPath = "SOFTWARE\CLASSES\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"

# Get a list of all user SIDs from the registry
$userSIDs = Get-ChildItem "registry::HKEY_USERS" | ForEach-Object { $_.Name }

# Iterate through each user SID and delete the registry key and its subkeys
foreach ($userSID in $userSIDs) {
    $regKeyPath = "registry::\$userSID\$regPath"
    if (Test-Path $regKeyPath) {
        Remove-Item -Path $regKeyPath -Recurse -Force
        Write-Host "Deleted registry key and subkeys for $userSID"
    }
    else {
        Write-Host "Registry key not found for $userSID"
    }
}


#restarts explorer for the icon size policy to take effect
Get-Process -Name explorer | Stop-Process -Force | Start-Process explorer.exe

}


