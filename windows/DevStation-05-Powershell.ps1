Write-Output ""
Write-Output "####################################"
Write-Output "Installing Powershell"
Write-Output "####################################"

if ( Get-Command winget -erroraction 'silentlycontinue' ){
    & winget install Microsoft.PowerShell --accept-package-agreements --accept-source-agreements
} 
elseif( Get-Command choco -erroraction 'silentlycontinue') {
    & choco install powershell-core -y
}

Write-Output "Finished"


Install-PackageProvider -Name NuGet -Force
Install-Module Nuget -Force -SkipPublisherCheck

Install-Module AWSPowerShell -Force
Import-Module AWSPowerShell

Install-Module Pester -Force -SkipPublisherCheck
Write-Output "Finished"

