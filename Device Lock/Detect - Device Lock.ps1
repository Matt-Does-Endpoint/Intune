#=============================================================================================================================
#
# Description:     Detect if devices in this group still have their TPM protectors
# Notes:           Remediate if TPM protectors are found on assigned devices
#
#=============================================================================================================================

# Define Variables

try {
$vol = Get-BitLockerVolume
$keyprotectors = $vol.KeyProtector
  
    if ($keyprotectors.keyprotectorType -contains "TPM"){ Write-Host "TPM Protectors are Present."
         Exit 1
    }
    else {

        Write-Host "TPM Protectors are Removed"
        exit 0
    }
}
catch {
    $errMsg = $_.Exception.Message
    return $errMsg
    exit 1
}
