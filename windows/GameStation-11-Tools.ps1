Write-Output ""
Write-Output "####################################"
Write-Output "Installing Software"
Write-Output "####################################"

# Sketchup
# AmazonPhotos
#    & winget install Mirantis.Lens
#    & winget install 9PGJGD53TN86 #Windbg Preview
#    & winget install 9N0DX20HK701 #Windows Terminal

$ErrorActionPreference = 'silentlycontinue'


$Packages = @()
if ( Get-Command winget ){
    if ( ! (Get-Command ghub) ){
        & winget install --force Logitech.GHUB
    }
    if ( ! (Get-Command chrome) ){
    & winget install --force Google.Chrome
    }
    if ( ! (Get-Command firefox) ){
    & winget install --force Mozilla.Firefox
    }
    if ( ! (Get-Command notepadplusplus) ){
    & winget install --force Notepad++.Notepad++
    }
    if ( ! (Get-Command foxitreader) ){
    & winget install --force Foxit.FoxitReader
    }
    if ( ! (Get-Command ccleaner) ){
    & winget install --force Piriform.CCleaner
    }
    if ( ! (Get-Command filezilla) ){
    & winget install --force TimKosse.FileZilla.Client
    }
    if ( ! (Get-Command lastpass) ){
    & winget install --force LogMeIn.LastPass
    }
    if ( ! (Get-Command slack) ){
    & winget install --force SlackTechnologies.Slack
    }
    if ( ! (Get-Command powertoys) ){
    & winget install --force Microsoft.PowerToys
    }
    if ( ! (Get-Command steam) ){
    & winget install --force Valve.Steam
    }
    if ( ! (Get-Command discord) ){
    & winget install --force Discord.Discord
    }
    if ( ! (Get-Command wiztree) ){
    & winget install --force AntibodySoftware.WizTree
    }
    if ( ! (Get-Command epic) ){
    & winget install --force EpicGames.EpicGamesLauncher
    }
    if ( ! (Get-Command rdpclient) ){
    & winget install --force Microsoft.RemoteDesktopClient
    }
    if ( ! (Get-Command cpuz) ){
    & winget install --force CPUID.CPU-Z
    }
    if ( ! (Get-Command cpuz) ){
    & winget install --force CPUID.CPU-Z.GBT
    }
    if ( ! (Get-Command aida64) ){
    & winget install --force FinalWire.AIDA64.Extreme
    }
    if ( ! (Get-Command hwinfo) ){
    & winget install --force REALiX.HWiNFO
    }
    if ( ! (Get-Command hwmonitor) ){
    & winget install --force CPUID.HWMonitor
    }
    if ( ! (Get-Command powermax) ){
    & winget install --force CPUID.powerMAX
    }
    if ( ! (Get-Command windowsterminal) ){
    & winget install --force Microsoft.WindowsTerminal
    }
    if ( ! (Get-Command code) ){
    & winget install --force Microsoft.VisualStudioCode
    }
    if ( ! (Get-Command java) ){
    & winget install --force Microsoft.OpenJDK.17
    & winget install --force Oracle.JavaRuntimeEnvironment
    }
    if ( ! (Get-Command qrcode) ){
    & winget install --force 9NZFK4DCXMZ4 #QR Code Scanner
    }
    if ( ! (Get-Command netflix) ){
    & winget install --force 9WZDNCRFJ3TJ #Neflix
    }
    if ( ! (Get-Command spotify) ){
    & winget install --force 9NCBCSZSJRSB #Spotify
    }
    if ( ! (Get-Command disney) ){
    & winget install --force 9NXQXXLFST89 #Disney+
    }
    if ( ! (Get-Command prime) ){
    & winget install --force 9P6RC76MSMMJ #Prime Video
    }
    if ( ! (Get-Command xerox) ){
    & winget install --force 9WZDNCRFJ1F8 #Xerox Print and Scan
    }
    if ( ! (Get-Command zoom) ){
    & winget install --force Zoom.Zoom
    }
    if ( ! (Get-Command obs) ){
    & winget install --force OBSProject.OBSStudio
    }
    if ( ! (Get-Command streamlabs) ){
#   & winget install --force Streamlabs.StreamlabsOBS
    }
    if ( ! (Get-Command mpc) ){
    & winget install --force clsid2.mpc-hc
    }
    if ( ! (Get-Command minecraftlauncher) ){
    & winget install --force Mojang.MinecraftLauncher
    }
    if ( ! (Get-Command angryip) ){
    & winget install --force angryziber.AngryIPScanner
    }
    if ( ! (Get-Command pandora) ){
    & winget install --force 9WZDNCRFJ46V # Pandora
    }
    if ( ! (Get-Command photos) ){
    & winget install --force 9WZDNCRFJBH4 # Microsoft Photos and Video Editor
    }
    if ( ! (Get-Command paint) ){
    & winget install --force 9NBLGGH5FV99 # Microsoft Paint 3d
    }

    
} 
elseif( Get-Command choco ) {
    $Packages = @( 
        @("lghub","logitechgaming","Latest"),
        @("googlechrome","googlechrome","Latest"),
        @("firefox","firefox","Latest"),
        @("notepadplusplus.install","notepadplusplus.install","Latest"),
        @("ccleaner","ccleaner","Latest"),
        @("foxitreader","foxitreader","Latest"),
        @("filezilla","filezilla","Latest"),
        @("lastpass","lastpass","Latest"),
        @("powertoys","powertoys","Latest"),
        @("vlc","vlc","Latest"),
        @("spotify","spotify","Latest"),
        @("steam","steam","Latest"),
        @("cpu-z.install","cpu-z.install","Latest"),
        @("slack","slack","Latest"),
        @("discord.install","discord.install","Latest"),
        @("hwinfo.install","hwinfo.install","Latest"),
        @("wiztree","wiztree","Latest"),
        @("powertoys","powertoys","Latest"),
        @("aws-iam-authenticator","aws-iam-authenticator","Latest"),
        @("epicgameslauncher","epicgameslauncher","Latest")
        )
}


$Packages += @( 
    @("lastpass-chrome","lastpass-chrome","Latest"),
    @("ublockorigin-chrome","ublockorigin-chrome","Latest"),
    @("ublockorigin-firefox","ublockorigin-firefox","Latest"),
    @("winbox","winbox","Latest")
    )



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
    } else {
        & choco install $ChocolateyPackageId $($chocoArgs)
    }
    
}





