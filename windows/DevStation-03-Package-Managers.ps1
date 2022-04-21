Write-Output ""
Write-Output "####################################"
Write-Output "Installing Package Managers"
Write-Output "####################################"

$chocInstalled = $false
if ( Get-Command choco -erroraction 'silentlycontinue' ){
    $chocInstalled = $true
} 
elseif( Get-Command refreshenv -erroraction 'silentlycontinue') {
    & refreshenv
    $chocInstalled = $true
}

if (-not $chocInstalled) {
    Write-Output "Installing Chocolatey"

    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 
    $installPs1 = "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"    
    Start-Process powershell -argument $installPs1 -wait -NoNewWindow

    $Env:Path += ";C:\ProgramData\chocolatey\bin"
    & refreshenv
}

#Disable Chocolatey download progress as it overloads log files
& choco feature disable -n=showDownloadProgress
& choco upgrade chocolatey -y
& refreshenv

Write-Host "Install Microsoft App Installer (winget)"
start-process ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1
Read-Host -Prompt "Press any key to continue"

Write-Host "Finished"

