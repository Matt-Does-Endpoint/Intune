#Remove URL
$UrlFile = "C:\Users\Public\Desktop\URLNAME.url"
$UrlFilePresence = test-path "$URLFile"

if ($UrlFilePresence -eq $true){

remove-item $UrlFile -Force
exit 0
}
