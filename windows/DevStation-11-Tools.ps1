$Packages = @( 
    @("nsclientplusplus.x64","nsclientplusplus.x64","Latest"),
    @("filebeat","filebeat","Latest"),
    @("winlogbeat","winlogbeat","Latest"),
    @("metricbeat","metricbeat","Latest"),
    @("auditbeat","auditbeat","Latest"),
    @("topbeat","topbeat","Latest"),
    @("golang","golang","Latest"),
    @("python","python","Latest"),
    @("wiztree","wiztree","Latest")
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
        "golang" {$chocoArgs += (' -ia INSTALLDIR="' + $Env:ChocolateyToolsLocation + '"\go')}
        "python" {$chocoArgs += (' --params "/InstallDir:' + $Env:ChocolateyToolsLocation + '\python"')}
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





