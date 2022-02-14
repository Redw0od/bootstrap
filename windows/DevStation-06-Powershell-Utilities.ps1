$MachineId = $OctopusParameters["Octopus.Machine.Id"]
$Packages = @( 
    @("Carbon","Carbon","Latest"),
    @("vim","vim","Latest"),
    @("7zip","7zip","Latest"),
    @("sysinternals","sysinternals","Latest"),
    @("git","git","Latest"),
    @("curl","curl","Latest"),
    @("AWSTools.Powershell","AWSTools.Powershell","Latest")
    )

Write-Output "Locating Chocolatey installation"
$chocolateyBin = [System.Environment]::GetEnvironmentVariable("ChocolateyInstall", "Machine") + "\bin"
$chocolateyTools = [System.Environment]::GetEnvironmentVariable("ChocolateyInstall", "Machine") + "\tools"
if(-not (Test-Path $chocolateyBin)) {
    Write-Output "Environment variable 'ChocolateyInstall' was not found in the system variables. Attempting to find it in the user variables..."
    $chocolateyBin = [Environment]::GetEnvironmentVariable("ChocolateyInstall", "User") + "\bin"
    $chocolateyTools = [System.Environment]::GetEnvironmentVariable("ChocolateyInstall", "User") + "\tools"
}

$cinst = "$chocolateyBin\cinst.exe"
$choco = "$chocolateyBin\choco.exe"

if (-not (Test-Path $cinst) -or -not (Test-Path $choco)) {
    throw "Chocolatey was not found at $chocolateyBin."
}

[System.Environment]::SetEnvironmentVariable("ChocolateyToolsLocation", $chocolateyTools, "Machine")
$Env:ChocolateyToolsLocation = $chocolateyTools
Set-Location $chocolateyTools
& choco feature disable -n=showDownloadProgress

$ChocoDetails = (& choco upgrade chocolatey --noop -r).Split("|")
[System.Version]$ChocoVersion = $ChocoDetails[1]
[System.Version]$ChocoLatest  = $ChocoDetails[2]
$ChocoUpgrade = [System.Convert]::ToBoolean($ChocoDetails[3])
Write-Output "Running Chocolatey version $ChocoVersion"

$ChocoApps = (choco list -l -r | %{$_.Split("|")[0]})

ForEach($Package in $Packages){
    
    $ChocolateyPackageId = $Package[0]
    $InstalledAppName = $Package[1]
    $ChocolateyPackageVersion = $Package[2]
    
    Write-Output "Checking for previous $InstalledAppName installation."
    if($ChocoApps -contains $InstalledAppName){
        Write-Output "Found $InstalledAppName installation, checking versions"
        $PackageDetails = (& choco upgrade $ChocolateyPackageId --noop -r).Split("|")
        [System.Version]$PackageVersion = $PackageDetails[1]
        [System.Version]$PackageLatest  = $PackageDetails[2]
        $PackageUpgrade = [System.Convert]::ToBoolean($PackageDetails[3])
    } else {
        Write-Output "$InstalledAppName Not Found."
        [System.Version]$PackageVersion = "0.0.1"
        $PackageUpgrade = $true
    }
    
    $chocoArgs = @("-y")
    switch($ChocolateyPackageId){
        "Carbon" {$chocoArgs += "; Import-Module Carbon"}
        "vim" {$chocoArgs += (' --params "/NoDesktopShortcuts /NoContextMenu /InstallDir:' + $Env:ChocolateyToolsLocation + '"')}
        "AWSTools.Powershell" {$chocoArgs += "; Install-Module AWSPowerShell -Force; Import-Module AWSPowerShell"}
    }
    
    
    Write-Output "Beginning installation"
    if ($PackageUpgrade){
        if($ChocolateyPackageVersion -eq "Latest" -or [string]::IsNullOrEmpty($ChocolateyPackageVersion)) {
            Write-Output "Installing package $ChocolateyPackageId from the Chocolatey package repository..."
            & choco upgrade $ChocolateyPackageId $($chocoArgs)
        } elseif([System.Version]$ChocolateyPackageVersion -gt [System.Version]$PackageVersion){
            Write-Output "Installing package $ChocolateyPackageId version $ChocolateyPackageVersion from the Chocolatey package repository..."
            & choco upgrade $ChocolateyPackageId -Version $ChocolateyPackageVersion $($chocoArgs)
        } elseif ([System.Version]$ChocolateyPackageVersion -eq [System.Version]$PackageVersion){
            Write-Output "$ChocolateyPackageId is already installed with the approved version $ChocolateyPackageVersion"
        } else {
            Write-Warning "$ChocolateyPackageId version $ChocolateyPackageVersion is newer than approved package version, $ChocolateyPackageVersion" -ErrorAction SilentlyContinue
        }
        refreshenv
    } elseif($ChocolateyPackageVersion -ne "Latest") {
        if([System.Version]$ChocolateyPackageVersion -lt [System.Version]$PackageVersion){
            Write-Warning "$ChocolateyPackageId version $ChocolateyPackageVersion is newer than approved package version, $ChocolateyPackageVersion" -ErrorAction SilentlyContinue
        } else {
            Write-Output "$ChocolateyPackageId is already installed with the approved version $ChocolateyPackageVersion"
        }
    }
    
}

#New-Item -Path C:\programdata\chocolatey\bin\vim.exe -ItemType SymbolicLink -Value 'C:\Program Files (x86)\vim\vim80\vim.exe'
#New-Item -Path C:\programdata\chocolatey\bin\7z.exe -ItemType SymbolicLink -Value 'C:\Program Files\7-Zip\7z.exe'
#New-Item -Path C:\programdata\chocolatey\bin\git.exe -ItemType SymbolicLink -Value 'C:\Program Files\Git\bin\git.exe'
try{
    $Nuget = Get-PackageProvider Nuget
} catch {
    write-output "Error loading Nuget"
}
try {
    $NugetOnline = Find-PackageProvider Nuget
} catch {
    write-output "Error loading Nuget Online"
}
if([string]::IsNullOrEmpty($Nuget.Version)){
    Write-Output "`nInstalling Nuget"
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module Nuget -Force -SkipPublisherCheck
} elseif ([System.Version]$Nuget.Version -lt [System.Version]$NugetOnline.Version){
    Write-Output "`nUpgrading Nuget"
    Install-PackageProvider -Name NuGet -Force
    Install-Module Nuget -Force -SkipPublisherCheck
}

try{
    $SQLLocal = Get-InstalledModule SQLServer
} catch {
    write-output "Error loading SQL Powershell Modules"
}
try {
    $SQLOnline = Find-Module SQLServer
} catch {
    write-output "Error loading SQL Modules Online"
}


Write-Output "`nChecking SQLServer Modules"
if([string]::IsNullOrEmpty($SQLLocal.Version)){
    Write-Output "`nInstalling SQLServer"
    Install-Module SQLServer -Force -SkipPublisherCheck
}elseif ([System.Version]$SQLLocal.Version -lt [System.Version]$SQLOnline.Version){
    Write-Output "`nUpgrading SQLServer"
    Install-Module SQLServer -Force -SkipPublisherCheck
}


Write-Output "`nInstalling SQL Server Modules"
Install-Module SQLServer -Force
Import-Module SQLServer



try{
    $PesterLocal = Get-InstalledModule Pester
} catch {
    write-output "Error Loading Pester Modules"
}
try {
    $PesterOnline = Find-Module Pester
} catch {
    write-output "Error Finding Pester"
}




Write-Output "`nInstalling Pester"
if([string]::IsNullOrEmpty($PesterLocal.Version)){
    Install-Module Pester -Force -SkipPublisherCheck
}elseif ([System.Version]$PesterLocal.Version -lt [System.Version]$PesterOnline.Version){
    Write-Output "`nUpgrading Pester"
    Install-Module Pester -Force -SkipPublisherCheck
}




Write-Output "Finished"