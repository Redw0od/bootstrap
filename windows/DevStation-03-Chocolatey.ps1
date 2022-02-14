Write-Output "Verifying Chocolatey installation"

$chocolateyBin = [Environment]::GetEnvironmentVariable("ChocolateyInstall", "Machine") + "\bin"
if(-not (Test-Path $chocolateyBin)) {
    Write-Output "Environment variable 'ChocolateyInstall' was not found in the system variables. Attempting to find it in the user variables..."
    $chocolateyBin = [Environment]::GetEnvironmentVariable("ChocolateyInstall", "User") + "\bin"
}
$chocInstalled = Test-Path "$chocolateyBin\cinst.exe"
try {
    choco
} catch {
    if($chocInstalled){
        if(-not $env:path -match "choco"){
            $Env:path += ";C:\ProgramData\chocolatey\bin"
        }
    }
    $chocInstalled = $false
}

if (-not $chocInstalled) {
    Write-Output "Chocolatey not found, installing..."
    #$installPs1 = ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
    $installPs1 = "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    Start-Process powershell -argument $installPs1 -wait -NoNewWindow
    $Env:Path += ";C:\ProgramData\chocolatey\bin"
    refreshenv
}
$powa = get-process -name powershell -IncludeUserName
Write-Output "$($powa.Username) : $($powa.ProcessName)"

$ChocoDetails = (choco upgrade chocolatey --noop -r).Split("|")
[System.Version]$ChocoVersion = $ChocoDetails[1]
[System.Version]$ChocoLatest  = $ChocoDetails[2]
$ChocoUpgrade = [System.Convert]::ToBoolean($ChocoDetails[3])
Write-Output "Chocolatey $ChocoVersion installed."

#Disable Chocolatey download progress as it overloads log files
& choco feature disable -n=showDownloadProgress

if ($ChocoUpgrade){
    if ($ChocolateyVersion -eq "Latest" -or [string]::IsNullOrEmpty($ChocolateyVersion)){
            Write-Output "Upgrading Chocolatey to the latest version"
            & choco upgrade chocolatey -y
    } elseif ([System.Version]$ChocolateyVersion -gt [System.Version]$ChocoVersion) {
        Write-Output "Upgrading Chocolatey to version $ChocolateyVersion"
        & choco upgrade -version $ChocolateyVersion -y
    } elseif ([System.Version]$ChocolateyVersion -eq [System.Version]$ChocoVersion) {
        Write-Output "Chocolatey is currently installed with approved version"
    } else {
        Write-Warning "Installed Chocolatey version $($ChocoVersion) is newer than approved version $ChocolateyVersion" -ErrorAction SilentlyContinue
    }
    refreshenv
} elseif($ChocolateyVersion -ne "Latest"){
    if ([System.Version]$ChocolateyVersion -lt [System.Version]$ChocoVersion) {
        Write-Warning "Installed Chocolatey version $($ChocoVersion) is newer than approved version $ChocolateyVersion" -ErrorAction SilentlyContinue
    } else {
        Write-Output "Chocolatey is currently installed with approved version"
    }
}

$chocolateyBin = [Environment]::GetEnvironmentVariable("ChocolateyInstall", "Machine") + "\bin"
$chocolateyTools = [System.Environment]::GetEnvironmentVariable("ChocolateyInstall", "Machine") + "\tools"
if(-not (Test-Path $chocolateyBin)) {
    Write-Output "Environment variable 'ChocolateyInstall' was not found in the system variables. Attempting to find it in the user variables..."
    $chocolateyBin = [Environment]::GetEnvironmentVariable("ChocolateyInstall", "User") + "\bin"
    $chocolateyTools = [System.Environment]::GetEnvironmentVariable("ChocolateyInstall", "User") + "\tools"
}
[System.Environment]::SetEnvironmentVariable("ChocolateyToolsLocation", $chocolateyTools, "Machine")
$Env:ChocolateyToolsLocation = $chocolateyTools
Set-Location $chocolateyTools


Write-Host "Finished"

