#Julien Destombes
#Script to configure local GPO

If (-not(Test-Path -Path C:\Windows\System32\GroupPolicy)) {
    Write-Host 'Create C:\Windows\System32\GroupPolicy folder'
    New-Item -Path C:\Windows\System32 -Name GroupPolicy -ItemType Directory
}

Write-Host 'Download https://stazurevirtualdesktop01.blob.core.windows.net/localgpo/gpt.ini file'
Invoke-WebRequest -Uri https://stazurevirtualdesktop01.blob.core.windows.net/localgpo/gpt.ini -OutFile C:\Windows\System32\GroupPolicy\gpt.ini

If (-not(Test-Path -Path C:\Windows\System32\GroupPolicy\User)) {
    Write-Host 'Create C:\Windows\System32\GroupPolicy\User folder'
    New-Item -Path C:\Windows\System32\GroupPolicy -Name User -ItemType Directory
}
If (-not(Test-Path -Path C:\Windows\System32\GroupPolicy\Machine)) {
    Write-Host 'Create C:\Windows\System32\GroupPolicy\Machine folder'
    New-Item -Path C:\Windows\System32\GroupPolicy -Name Machine -ItemType Directory
}

Write-Host 'Download https://stazurevirtualdesktop01.blob.core.windows.net/localgpo/Registry_User.pol file'
Invoke-WebRequest -Uri https://stazurevirtualdesktop01.blob.core.windows.net/localgpo/Registry_User.pol -OutFile C:\Windows\System32\GroupPolicy\User\Registry.pol

gpupdate /force