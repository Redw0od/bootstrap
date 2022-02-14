$MachineId = $OctopusParameters["Octopus.Machine.Id"]
$ChocolateyPackageId = $dotNetPackageId.trim()
$InstalledAppName = $dotNetInstalledName.trim()
$ChocolateyPackageVersion = $dotNetVersion.trim()

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
$Chocolatey = "C:\ProgramData\chocolatey\choco.exe"

if (-not (Test-Path $cinst) -or -not (Test-Path $choco)) {
    throw "Chocolatey was not found at $chocolateyBin."
}
$ThePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
write-output "PATH: $($ThePath)"
try {
    choco
} catch {
    if(-not $env:path -match "choco"){
        $ThePath += ";C:\ProgramData\chocolatey\bin"
        [System.Environment]::SetEnvironmentVariable('Path',$ThePath,[System.EnvironmentVariableTarget]::Machine)
    }
}

write-output "PATH: $([System.Environment]::GetEnvironmentVariable('Path', 'Machine'))"
$refreshenv = "refreshenv"
try{
   & $refreshenv
} catch {
    $refreshenv = "C:\ProgramData\chocolatey\bin\RefreshEnv.cmd"
}


[System.Environment]::SetEnvironmentVariable("ChocolateyToolsLocation", $chocolateyTools, "Machine")
$Env:ChocolateyToolsLocation = $chocolateyTools
Set-Location $chocolateyTools

& $Chocolatey feature disable -n=showDownloadProgress

$ChocoDetails = (& $Chocolatey upgrade chocolatey --noop -r).Split("|")
$ChocoVersion = $ChocoDetails[1]
$ChocoLatest  = $ChocoDetails[2]
$ChocoUpgrade = [System.Convert]::ToBoolean($ChocoDetails[3])
Write-Output "Running Chocolatey version $ChocoVersion"

$ChocoApps = (& $Chocolatey list -l -r | %{$_.Split("|")[0]})

Write-Output "Checking for previous $InstalledAppName installation."
if($ChocoApps -contains $InstalledAppName){
    $PackageDetails = ( & $Chocolatey upgrade $ChocolateyPackageId --noop -r).Split("|")
    [System.Version]$PackageVersion = $PackageDetails[1]
    [System.Version]$PackageLatest  = $PackageDetails[2]
    $PackageUpgrade = [System.Convert]::ToBoolean($PackageDetails[3])
} else {
    [System.Version]$PackageVersion = "0.0.1"
    $PackageUpgrade = $true
}

$chocoArgs = @("-y")

Write-Output "Beginning installation"
if ($PackageUpgrade){
    if($ChocolateyPackageVersion -eq "Latest" -or [string]::IsNullOrEmpty($ChocolateyPackageVersion)) {
        Write-Output "Installing package $ChocolateyPackageId from the Chocolatey package repository..."
        & $Chocolatey upgrade $ChocolateyPackageId $($chocoArgs)
        Set-OctopusVariable -Name $MachineId -Value 1
    } elseif([System.Version]$ChocolateyPackageVersion -gt [System.Version]$PackageVersion){
        Write-Output "Installing package $ChocolateyPackageId version $ChocolateyPackageVersion from the Chocolatey package repository..."
        & $Chocolatey upgrade $ChocolateyPackageId -Version $ChocolateyPackageVersion $($chocoArgs)
        Set-OctopusVariable -Name $MachineId -Value 1
    } elseif ([System.Version]$ChocolateyPackageVersion -eq [System.Version]$PackageVersion){
        Write-Output "$ChocolateyPackageId is already installed with the approved version $ChocolateyPackageVersion"
    } else {
        Write-Warning "$ChocolateyPackageId version $ChocolateyPackageVersion is newer than approved package version, $ChocolateyPackageVersion" -ErrorAction SilentlyContinue
    }
    $refreshenv
} elseif($ChocolateyPackageVersion -ne "Latest") {
    if([System.Version]$ChocolateyPackageVersion -lt [System.Version]$PackageVersion){
        Write-Warning "$ChocolateyPackageId version $ChocolateyPackageVersion is newer than approved package version, $ChocolateyPackageVersion" -ErrorAction SilentlyContinue
    } else {
        Write-Output "$ChocolateyPackageId is already installed with the approved version $ChocolateyPackageVersion"
    }
}

Write-Output "Finished"

