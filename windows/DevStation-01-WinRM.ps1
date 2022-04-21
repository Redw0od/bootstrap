# (New-Object System.Net.WebClient).DownloadString('https://github.com/Redw0od/dotfiles/blob/master/.bashrc')

if((get-service winrm).status -ne "Running"){
    Write-Output "Starting WinRM"
    Start-Service winrm
}

#Test WinRM service before calling WSMan settings
#Assign octopus Variables to Script variables
$SettingWinRMMaxTimeoutms = "30000"
$SettingWinRMServiceBasic = $false
$SettingWinRMServiceCredSSP = $true
$SettingWinRMCbtHardeningLevel = "strict"
$SettingWinRMEnableCompatibilityHttpListener = $false
$SettingWinRMEnableCompatibilityHttpsListener = $false
$SettingWinRMClientBasic = $false
$SettingWinRMClientDigest = $false

Write-Output "Collecting WinRM Configuration Details"
$MaxTimeoutms = Get-Item WSMan:\localhost\MaxTimeoutms
$ServiceBasic = Get-Item WSMan:\localhost\Service\Auth\Basic
$ServiceCredSSP = Get-Item WSMan:\localhost\Service\Auth\CredSSP
$ServiceCbtHardeningLevel = Get-Item WSMan:\localhost\Service\Auth\CbtHardeningLevel
$EnableCompatibilityHttpListener = Get-Item WSMan:\localhost\Service\EnableCompatibilityHttpListener
$EnableCompatibilityHttpsListener = Get-Item WSMan:\localhost\Service\EnableCompatibilityHttpsListener
$ClientBasic = Get-Item WSMan:\localhost\Client\Auth\Basic
$ClientCredSSP = Get-Item WSMan:\localhost\Client\Auth\CredSSP
$ClientDigest = Get-Item WSMan:\localhost\Client\Auth\Digest
$UpdateWinRM = $false


# Configure UAC to allow privilege elevation in remote shells
Write-Output  "Enabling UAC for shells"
$Key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$Setting = 'LocalAccountTokenFilterPolicy'
Set-ItemProperty -Path $Key -Name $Setting -Value 1 -Force

# Configure Firewall to allow WinRM
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new action=allow localip=any remoteip=any

if([string]::IsNullOrEmpty($MaxTimeoutms.SourceOfValue) -and $MaxTimeoutms.Value -ne $SettingWinRMMaxTimeoutms){
    Write-Output "Updating MaxTimeoutms"
    $UpdateWinRM = $true
    $MaxTimeoutms | Set-Item -Value $SettingWinRMMaxTimeoutms
}
if([string]::IsNullOrEmpty($ServiceBasic.SourceOfValue) -and $ServiceBasic.Value -ne $SettingWinRMServiceBasic){
    Write-Output "Updating ServiceBasic"
    $UpdateWinRM = $true
    $ServiceBasic | Set-Item -Value $SettingWinRMServiceBasic
}
if([string]::IsNullOrEmpty($ServiceCredSSP.SourceOfValue) -and $ServiceCredSSP.Value -ne $SettingWinRMServiceCredSSP){
    Write-Output "Updating ServiceCredSSP"
    $UpdateWinRM = $true
    $ServiceCredSSP | Set-Item -Value $SettingWinRMServiceCredSSP
}
if([string]::IsNullOrEmpty($ServiceCbtHardeningLevel.SourceOfValue) -and $ServiceCbtHardeningLevel.Value -ne $SettingWinRMCbtHardeningLevel){
    Write-Output "Updating ServiceCbtHardeningLevel"
    $UpdateWinRM = $true
    $ServiceCbtHardeningLevel | Set-Item -Value $SettingWinRMCbtHardeningLevel
}
if([string]::IsNullOrEmpty($EnableCompatibilityHttpListener.SourceOfValue) -and $EnableCompatibilityHttpListener.Value -ne $SettingWinRMEnableCompatibilityHttpListener){
    Write-Output "Updating EnableCompatibilityHttpListener"
    $UpdateWinRM = $true
    $EnableCompatibilityHttpListener | Set-Item -Value $SettingWinRMEnableCompatibilityHttpListener
}
if([string]::IsNullOrEmpty($EnableCompatibilityHttpsListener.SourceOfValue) -and $EnableCompatibilityHttpsListener.Value -ne $SettingWinRMEnableCompatibilityHttpsListener){
    Write-Output "Updating EnableCompatibilityHttpsListener"
    $UpdateWinRM = $true
    $EnableCompatibilityHttpsListener | Set-Item -Value $SettingWinRMEnableCompatibilityHttpsListener
}
if([string]::IsNullOrEmpty($ClientBasic.SourceOfValue) -and $ClientBasic.Value -ne $WinRMClientBasic){
    Write-Output "Updating ClientBasic"
    $UpdateWinRM = $true
    $ClientBasic | Set-Item -Value $SettingWinRMClientBasic
}
if([string]::IsNullOrEmpty($ClientCredSSP.SourceOfValue) -and $ClientCredSSP.Value -ne $SettingWinRMClientBasic){
    Write-Output "Updating ClientCredSSP"
    $UpdateWinRM = $true
    $ClientCredSSP | Set-Item -Value $SettingWinRMClientBasic
}
if([string]::IsNullOrEmpty($ClientDigest.SourceOfValue) -and $ClientDigest.Value -ne $SettingWinRMClientDigest){
    Write-Output "Updating ClientDigest"
    $UpdateWinRM = $true
    $ClientDigest | Set-Item -Value $SettingWinRMClientDigest
}

# Configure and restart the WinRM Service; Enable the required firewall exception
if($UpdateWinRM){
    Write-Output  "Applying settings and restarting WinRM"
    Stop-Service -Name WinRM
    Set-Service -Name WinRM -StartupType Automatic
    Start-Service -Name WinRM
}

Write-Output  "Enabling PSRemoting"
Enable-PSRemoting -Force

Write-Output "Finished"

