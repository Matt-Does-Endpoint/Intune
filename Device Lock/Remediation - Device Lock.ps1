#=============================================================================================================================
#
# Description:     This script Locks Devices
# Notes:  Remediate if TPM protectors are found on assigned devices
#
#=============================================================================================================================

try {
#FIX 
#Manage-bde -protectors -add C: -tpm
# Variables
$Target = "$env:ProgramData\Scripts"

# If local path for script doesn't exist, create it
If (!(Test-Path $Target)) { New-Item -Path $Target -Type Directory -Force }

#Create the PS1 File
New-item "C:\ProgramData\Scripts\Fixlock.ps1" -ItemType File -Force

#Write the Code into the fix PS1
Set-Content -encoding UTF8 -PassThru "C:\ProgramData\Scripts\Fixlock.ps1" 'Manage-bde -protectors -add C: -tpm'

#sets runonce to re-add protectors at next boot.
reg.exe add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "FixLock" /t REG_SZ /d "powershell.exe -executionpolicy Bypass -Windowstyle Hidden -file C:\Programdata\Scripts\FixLock.ps1" /f | Out-Host

#Locks Device Out
$Driveletter = "C:"
manage-bde -forcerecovery $Driveletter
$vol = Get-BitLockerVolume
$keyprotectors = $vol.KeyProtector


   if ($keyprotectors.keyprotectorType -notcontains "TPM"){
        Write-Host "TPM Protectors have been Removed!"
        Restart-Computer -Force
    }
    else{
        Write-Host "Lock Failed"
        }
}
catch{
    $errMsg = $_.Exception.Message
    return $errMsg
    exit 1
}