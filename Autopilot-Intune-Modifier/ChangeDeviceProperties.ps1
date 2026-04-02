# Install the AzureAD module if not already installed
if (-not (Get-Module -Name AzureAD -ListAvailable)) {
    Install-Module -Name AzureAD -Force
}
import-module -Name AzureAD -Force


# Install the AzureAD module if not already installed
if (-not (Get-Module -Name Microsoft.Graph.Authentication -ListAvailable)) {
    Install-Module -Name Microsoft.Graph.Authentication -Force
}

import-module -Name Microsoft.Graph.Authentication -Force

Update-MSGraphEnvironment -AppId #XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
Connect-MSGraph
Connect-MGGraph -Scopes "DeviceManagementManagedDevices.ReadWrite.All","DeviceManagementManagedDevices.PrivilegedOperations.All"
#Select-MgProfile -Name "beta"
Update-MSGraphEnvironment -SchemaVersion "Beta" 
#group ID of your azure AD group

$groupId = #"XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

# Step 1: Get all device members of the Azure AD group
$AzureGroupDevices = Invoke-MSGraphRequest -HttpMethod GET -Url "groups/$groupId/members" | Get-MSGraphAllPages

# Step 2: Extract the device names and ID's from the group members (to cross reference to intune records)
$deviceNames = foreach ($device in $AzureGroupDevices) {
    if ($device.'@odata.type' -eq '#microsoft.graph.device') {
        # You could also return the device ID here if necessary
        [PSCustomObject]@{
            DeviceName = $device.displayName
            DeviceId = $device.id  # Optional, in case you need the device ID for cross-referencing
            EnrollmentProfileName = $device.enrollmentProfileName
            ApproximateLastSignInDateTime = $device.approximateLastSignInDateTime
            
        }
    }
}


#LastSignInDateTime = $device.approximateLastSignInDateTime
# Step 3: Retrieve all devices from Intune (to reference against Autopilot records)
$allIntuneDevices = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/managedDevices" | Get-MSGraphAllPages


# Step 4: Cross-reference the device names from the Azure AD group with the Intune records to get serial numbers
$deviceSerials = foreach ($device in $deviceNames) {
    $matchingIntuneDevice = $allIntuneDevices | Where-Object { $_.deviceName -eq $device.DeviceName }

    if ($matchingIntuneDevice) {
        [PSCustomObject]@{
            DeviceName          = $matchingIntuneDevice.deviceName
            SerialNumber        = $matchingIntuneDevice.serialNumber
            DeviceId            = $matchingIntuneDevice.id
            EnrollmentProfileName = $device.EnrollmentProfileName
            UserDisplayName     = $matchingIntuneDevice.userDisplayName
            ManagedDeviceName   = $matchingIntuneDevice.managedDeviceName
            Model = $matchingIntuneDevice.Model
            FreeStorageBytes    = $matchingIntuneDevice.freeStorageSpaceInBytes
            totalStorageBytes    = $matchingIntuneDevice.totalStorageSpaceInBytes
            LastSyncDateTime            = $matchingIntuneDevice.lastSyncDateTime
            ApproximateLastSignInDateTime = $device.ApproximateLastSignInDateTime
        }
    }
}



# Step 5: Get all Autopilot devices (even if there are more than 1000, use paging)ds
$autopilotDevices = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/windowsAutopilotDeviceIdentities" | Get-MSGraphAllPages

# Step 6: Get all Autopilot Deployment Profiles
$autopilotProfiles = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/windowsAutopilotDeploymentProfiles" | Get-MSGraphAllPages

# Step 7: Filter Autopilot devices by serial number (from the previous list of serials)
$filteredAutopilotDevices = foreach ($device in $autopilotDevices) {
    if ($deviceSerials.SerialNumber -contains $device.serialNumber) {
        
        # Match the device to its corresponding Intune record
        $matchingIntuneDevice = $allIntuneDevices | Where-Object { $_.serialNumber -eq $device.serialNumber }

        # Return the enriched object with original properties + new ones
        [PSCustomObject]@{
            AutopilotDeviceName = $device.displayName
            IntuneDeviceName     = if ($matchingIntuneDevice) { $matchingIntuneDevice.deviceName } else { "Not Found in Intune" }
            SerialNumber         = $device.serialNumber
            GroupTag             = $device.groupTag
            EnrollmentState      = $device.enrollmentState
            AutopilotID          = $device.id

            # --- Azure AD values ---
            EnrollmentProfile    = ($deviceSerials | Where-Object { $_.SerialNumber -eq $device.serialNumber }).EnrollmentProfileName
            ApproximateLastSignInDateTime   = ($deviceSerials | Where-Object { $_.SerialNumber -eq $device.serialNumber }).ApproximateLastSignInDateTime

            # --- Intune values ---
            LastSyncDateTime            = if ($matchingIntuneDevice) { $matchingIntuneDevice.lastSyncDateTime } else { $null }
            UserDisplayName      = if ($matchingIntuneDevice) { $matchingIntuneDevice.userDisplayName } else { $null }
            Model      = if ($matchingIntuneDevice) { $matchingIntuneDevice.Model } else { $null }
            ManagedDeviceName    = if ($matchingIntuneDevice) { $matchingIntuneDevice.managedDeviceName } else { $null }
            FreeStorageGB        = if ($matchingIntuneDevice -and $matchingIntuneDevice.freeStorageSpaceInBytes) {
                                       [math]::Round($matchingIntuneDevice.freeStorageSpaceInBytes / 1GB, 2)
                                   } else { $null }
            totalStorageGB        = if ($matchingIntuneDevice -and $matchingIntuneDevice.totalStorageSpaceInBytes) {
                                       [math]::Round($matchingIntuneDevice.totalStorageSpaceInBytes / 1GB, 2)
                                   } else { $null }
        }
    }
}


#Export list for purely informational purposes.
##############################################################################
#export all
#$filteredAutopilotDevices | export-csv "$ENV:OneDriveCommercial\Desktop\CompiledDeviceList.csv" -Force

#export selected
#$selectedAutopilotDevices = $filteredAutopilotDevices | Out-GridView -OutputMode Multiple -Title "Select Windows Autopilot entities to update" | export-csv "$ENV:OneDriveCommercial\Desktop\CompiledDeviceList.csv" -Force
##############################################################################

# Step 8: Display gridview to show enriched Autopilot records
$selectedAutopilotDevices = $filteredAutopilotDevices | Out-GridView -OutputMode Multiple -Title "Select Windows Autopilot entities to update"
##############################################################################
##############################################################################
##############################################################################
##############################################################################

#CHANGES BELOW ARE APPLIED BASED ON THE HIGHLIGHTED AND SELECTED DEVICES FROM PREVIOUS WINDOW
# Step 9: Assign a group tag and rename the corresponding Intune devices. Also optionally clear autopilot Name
$selectedAutopilotDevices | ForEach-Object {
    $autopilotDevice = $_

    # Define new Group Tag and the new Intune device name format. Leave the quotes for $autopilotDevice.AutopilotDeviceName blank to clear the existing device name.
    
    #group tag and device name info
    $autopilotDevice.groupTag = "GROUP TAG HERE"
    $intuneDevicePrefix = "XXX"
    #new Intune deviceName

    $newIntuneDeviceName = "$intuneDevicePrefix-$($autopilotDevice.SerialNumber)-EXTRADEVICENAMECHARS"
    $autopilotDevice.AutopilotDeviceName = "$newIntuneDeviceName"
    
    #if you want to match the autopilot record to the intune serial number instead of clearing the record name, swap the below line with the previously defined matching variable.
    $autopilotDevice.AutopilotDeviceName = "$intuneDevicePrefix-$($autopilotDevice.SerialNumber)-EXTRADEVICENAMECHARS"

    # --- (Optional) Update Autopilot record's groupTag ---
    $apRequestBody = @{
        groupTag = $autopilotDevice.groupTag
    } | ConvertTo-Json -Depth 2

    Write-Output "Updating Autopilot record: $($autopilotDevice.AutopilotID) | groupTag: $($autopilotDevice.groupTag)"
    Invoke-MgGraphRequest -Method POST `
        -Uri "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities/$($autopilotDevice.AutopilotID)/updateDeviceProperties" `
        -Body $apRequestBody `
        -ContentType "application/json"


    # --- (Optional) Update Autopilot record's device name ---
    #$apRequestBody = @{
    #    displayName = $autopilotDevice.AutopilotDeviceName
    #} | ConvertTo-Json -Depth 2

    #Write-Output "Updating Autopilot record: $($autopilotDevice.AutopilotID) | AutoPilotDeviceName: $($autopilotDevice.AutopilotDeviceName)"
    #Invoke-MgGraphRequest -Method POST `
    #    -Uri "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities/$($autopilotDevice.AutopilotID)/updateDeviceProperties" `
    #    -Body $apRequestBody `
    #    -ContentType "application/json"



    # --- (Optional) Rename the corresponding Intune Managed Device ---
    if ($matchingIntuneDevice) {
        $renameBody = @{
            deviceName = $newIntuneDeviceName
        } | ConvertTo-Json -Depth 2
    
        Write-Output "Renaming Intune device: $($matchingIntuneDevice.id) | new name: $newIntuneDeviceName"
    
        Invoke-MgGraphRequest -Method POST `
            -Uri "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($matchingIntuneDevice.id)/setDeviceName" `
           -Body $renameBody `
            -ContentType "application/json"
    }
    else {
        Write-Warning "No Intune managedDevice found for serial $($autopilotDevice.SerialNumber)"
    }
}



#Step 10: Invoke an autopilot service sync to finalize changes
Invoke-MSGraphRequest -HttpMethod POST -Url "deviceManagement/windowsAutopilotSettings/sync"
