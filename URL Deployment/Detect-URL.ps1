#change the $DesiredURL here and in the deployment script and re-upload.
$DesiredURL = "https://WEBADDRESS"
$UrlFile = "C:\Users\Public\Desktop\URLNAME.url"
$UrlFilePresence = test-path "$URLFile"

if ($UrlFilePresence -eq $true){
$Target  = (Get-Content $UrlFile | Where-Object { $_ -match '^URL=' }) -replace '^URL=', ''
}

if ($Target -eq $DesiredURL -and $URLFilePresence -eq $true) {
write-host "URL matches and icon is present!!"
Exit 0
}else {
write-host "URL doesn't match or file isn't present!"
Exit 1
}
