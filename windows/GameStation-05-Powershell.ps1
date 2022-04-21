Write-Output ""
Write-Output "####################################"
Write-Output "Installing Powershell"
Write-Output "####################################"

if ( Get-Command winget -erroraction 'silentlycontinue' ){
    & winget install Microsoft.PowerShell
} 
elseif( Get-Command choco -erroraction 'silentlycontinue') {
    & choco install powershell-core -y
}

Write-Output "Finished"

