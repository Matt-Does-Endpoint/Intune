# Variables for the HKCU key you want to change for all users
$RegPath = "SOFTWARE\Microsoft\Office\16.0\Outlook\Options\Calendar"
$RegName = "Value Here"
$RegValue = 1

# Get SIDs for all users
$UserSIDs = Get-ChildItem -Path 'REGISTRY::\HKEY_USERS' | Where-Object { $_.Name -notlike '*Classes' } | ForEach-Object { $_.PSChildName }

# Define accounts to exclude from ACL modifications
$ExcludedAccounts = @("SYSTEM", "Administrator", "Default", "Local Service", ".Default", "Network Service")

# Loop through each user SID
ForEach ($SID in $UserSIDs) {
    try {
        $User = New-Object System.Security.Principal.SecurityIdentifier($SID)
        $UserAccount = $User.Translate([System.Security.Principal.NTAccount]).Value
        $UserName = $UserAccount.Split('\\')[-1]  # Extract only the username
    } catch {
        #Write-Host "Skipping invalid SID: $SID"
        Continue
    }
    
    # Skip excluded accounts
    if ($ExcludedAccounts -contains $UserName) {
        Continue
    }
    
    $RegUserPath = "REGISTRY::\HKEY_USERS\$SID\$RegPath"
    
    # Check if the registry path exists, create if not
    if (!(Test-Path "$RegUserPath")) {
        New-Item -Path "$RegUserPath" -Force | Out-Null -ErrorAction SilentlyContinue
        Write-Host "Created registry key $RegPath for user $UserName."
    }
    
    # Set or modify the registry value
    New-ItemProperty -Path "$RegUserPath" -Name $RegName -Value $RegValue -PropertyType DWORD -Force | Out-Null
    Write-Host "Set registry value $RegName for user $UserName."
}
