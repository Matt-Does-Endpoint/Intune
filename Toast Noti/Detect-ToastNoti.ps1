$osVersion = (Get-ComputerInfo | Select-Object -expand OsName)
$timechecked = get-date

if ($osVersion -match "11")
{
    Write-Host "Windows 11, exiting message!"
    exit 0
    
}elseif ($osVersion -match "10")
{
write-host "pop up displayed at $Timechecked"
exit 1
}
