# Variables for the key you want to detect for all users
$RegPath = "SOFTWARE\CLASSES\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
$RegValueName = "(default)"

# SIDS for all users
$UserSIDs = Get-ChildItem -Path 'REGISTRY::\HKEY_USERS' | Where-Object { $_.Name -notlike '*Classes' } | ForEach-Object { $_.PSChildName }

$foundKeys = $false

# Loop through each user and check if the key and value exist
ForEach ($SID in $UserSIDs) {
    $RegUserPath = "REGISTRY::\HKEY_USERS\$SID\$RegPath"
    if (Test-Path "$RegUserPath") {
        $RegUserValue = (Get-ItemProperty -Path $RegUserPath -Name $RegValueName -ErrorAction SilentlyContinue)."($RegValueName)"
        if ($RegUserPath -ne $null) {
            $foundKeys = $true

        }
    }
}

if ($foundKeys) {
    
            Write-Host "Registry key and value detected for user with SID $SID"
            Write-Host "Key path: $RegUserPath"
            Write-Host "Value name: $RegValueName"
            Write-Host "Value data: $RegUserValue"
            Write-Host "---"
} 
