
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Output "#Hostname#" 

$env:COMPUTERNAME



Write-Output "#Host_OS#" 

Get-ComputerInfo | select WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer | ConvertTo-Json



Write-Output "#Host_KB#"

Get-Hotfix | Select-Object HotFixID | ConvertTo-json



Write-Output "#Host_Process#"

Get-Process | Select-Object -Property Name, Id, Description | Sort-Object -Property Name -Uniq  | ConvertTo-Json



Write-Output "#Host_Service#"

Get-Service | Select-Object -Property Status, Name, DisplayName | ConvertTo-Json



Write-Output "#Host_open_connections#"

Get-NetTCPConnection -State Listen, Established | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State | ConvertTo-Json



Write-Output "#Host_apps#"

Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate  | ConvertTo-Json



Write-Output "#Host_users#"

Get-LocalUser | Select-Object Name, Enabled | ConvertTo-Json



Write-Output "#Host_groups#"

Get-LocalGroup | Select-Object Name, Description | ConvertTo-Json
