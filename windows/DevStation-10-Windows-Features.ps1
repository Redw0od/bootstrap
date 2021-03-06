Write-Output ""
Write-Output "####################################"
Write-Output "Install Windows Features / WSL"
Write-Output "####################################"

Install-WindowsFeature RSAT-AD-Tools
Install-WindowsFeature UpdateServices-API

Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -NoRestart
Enable-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -Online
wsl.exe --install -d Debian
wsl.exe --set-default-version 2