#VERSION 1 That waits for a window to be open
do{ start-sleep -Seconds 1 }until($wshell.AppActivate('Application Window Title Here') -eq "True" )

#$started = $false



Do {

    $status = Get-Process Explorer -ErrorAction SilentlyContinue

    If (!($status)) { Write-Host 'Waiting for explorer to start' ; Start-Sleep -Seconds 10 }

    Else { start-process ".\setup.exe" -ArgumentList '/whatever /silent' -wait ; $started = $true }

}
Until ( $started )
