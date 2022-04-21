Write-Output ""
Write-Output "####################################"
Write-Output "Installing Windows Features"
Write-Output "####################################"

Install-WindowsFeature RSAT-AD-Tools
Install-WindowsFeature UpdateServices-API

Enable-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -Online
Enable-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V -All -Online
