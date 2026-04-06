# Replace these with your actual values
$companyName = "Company.com"
$csvFilePath = "C:\Users\$env:Username\OneDrive - $companyName\Desktop\CSVLIST.csv"
$groupName = "Group.AddDevices.to.me"

# Read the CSV file
$devices = Import-Csv -Path $csvFilePath
#name of the column in the CSV. Depending on where you generate your report from in intune, it could be DeviceName or DisplayName
$CategoryType = 'DeviceName'

# Install the AzureAD module if not already installed
if (-not (Get-Module -Name AzureAD -ListAvailable)) {
    Install-Module -Name AzureAD -Force
}

# Connect to Azure AD
Connect-AzureAD

# Get the Azure AD group
$group = Get-AzureADGroup -Filter "DisplayName eq '$groupName'"

if ($group -eq $null) {
    Write-Host "Azure AD group '$groupName' not found."
    Disconnect-AzureAD
    #exit
}

try {
    $groupObj = Get-AzureADGroup -SearchString $groupName
    foreach ($device in $devices) {
        $deviceObj = Get-AzureADDevice -SearchString $device.$CategoryType -All $true
        if($deviceObj -ne $null){
            try{
                foreach($dev in $deviceObj){
                    
                        Add-AzureADGroupMember -ObjectId $groupObj.ObjectId -RefObjectId $dev.ObjectId       
                    }
                
            }
            catch{}
        }
        else{
           Write-Host "No device found:$($device.$CategoryType)"
        }
    }
}
catch {
    Write-Host -Message $_
}
