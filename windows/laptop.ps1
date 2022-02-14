#Octopus Scripts should assign Octopus variables at beginning

# Setup Dev Station
## Setup WinRM
### WinRM needs to test service before calling wsman
## Setup TimeZone
## Install Chocolatey
### Call Invoke-Expression as part of Start-Process
#Firefox Default
#firefox lastpass
# Set Explorer to show hidden items and file extensions
# Disable Driver updates, System -> Hardware -> Device installation

Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform


$Packages = @( 
    @("Carbon","Carbon","Latest"),
    @("vim","vim","Latest"),
    @("7zip","7zip","Latest"),
    @("sysinternals","sysinternals","Latest"),
    @("git","git","Latest"),
    @("curl","curl","Latest"),
    @("AWSTools.Powershell","AWSTools.Powershell","Latest"),
    @("awscli","awscli","Latest"),
    @("googlechrome","googlechrome","Latest"),
    @("firefox","firefox","Latest"),
    @("vlc","vlc","Latest"),
    @("notepadplusplus.install","notepadplusplus.install","Latest"),
    @("github-desktop","github-desktop","Latest"),
    @("git.install","git.install","Latest"),
    @("openssh","openssh","Latest"),
    @("ccleaner","ccleaner","Latest"),
    @("foxitreader","foxitreader","Latest"),
    @("filezilla","filezilla","Latest"),
    @("python","python","Latest"),
    @("dotnetfx","dotnetfx","Latest"),
    @("winscp.install","winscp.install","Latest"),
    @("dropbox","dropbox","Latest"),
    @("vscode","vscode","Latest"),
    @("nuget.commandline","nuget.commandline","Latest"),
    @("wireshark","wireshark","Latest"),
    @("office365business","office365business","Latest"),
    @("golang","golang","Latest"),
    @("microsoft-teams.install","microsoft-teams.install","Latest"),
    @("spotify","spotify","Latest"),
    @("steam","steam","Latest"),
    @("slack","slack","Latest"),
    @("googledrive","googledrive","Latest"),
    @("terraform","terraform","Latest"),
    @("pester","pester","Latest"),
    @("cpu-z.install","cpu-z.install","Latest"),
    @("gpg4win","gpg4win","Latest"),
    @("pip","pip","Latest"),
    @("nmap","nmap","Latest"),
    @("lastpass","lastpass","Latest"),
    @("lastpass-chrome","lastpass-chrome","Latest"),
    @("ublockorigin-chrome","ublockorigin-chrome","Latest"),
    @("ublockorigin-firefox","ublockorigin-firefox","Latest"),
    @("packer","packer","Latest"),
    @("winbox","winbox","Latest"),
    @("selenium","selenium","Latest"),
    @("selenium-chrome-driver","selenium-chrome-driver","Latest"),
    @("nvidia-display-driver","nvidia-display-driver","Latest"),
    @("teamviewer","teamviewer","Latest"),
    @("discord.install","discord.install","Latest"),
    @("autoit.install","autoit.install","Latest"),
    @("hwinfo.install","hwinfo.install","Latest"),
    @("google-backup-and-sync","google-backup-and-sync","Latest"),
    @("sketchup","sketchup","Latest"),
    @("windbg","windbg","Latest"),
    @("angryip","angryip","Latest"),
    @("wiztree","wiztree","Latest"),
    @("intel-dsa","intel-dsa","Latest"),
    @("epicgameslauncher","epicgameslauncher","Latest"),
    @("razer-synapse-2","razer-synapse-2","Latest"),
    @("prey","prey","Latest"),
    @("cloudberryexplorer.s3","cloudberryexplorer.s3","Latest")
    )

Foreach($Package in $Packages){
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


    $chocoArgs = @(" -y")
    switch($ChocolateyPackageId){
        "vim" {$chocoArgs += (' --params "/NoDesktopShortcuts /NoContextMenu /InstallDir:' + $Env:ChocolateyToolsLocation + '"')}
        "golang" {$chocoArgs += (' -ia INSTALLDIR="' + $Env:ChocolateyToolsLocation + '"\go')}
        "python" {$chocoArgs += (' --params "/InstallDir:' + $Env:ChocolateyToolsLocation + '\python"')}
        default {$chocoArgs += (' --params "/NoDesktopShortcuts"')}
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

$PotentialPackages = @( 
    @("goggalaxy","goggalaxy","Latest"),
    @("rainmeter","rainmeter","Latest"),
    @("stellarium","stellarium","Latest"),
    @("handle","handle","Latest"),
    @("superbenchmarker","superbenchmarker","Latest"),
    @("advanced-ip-scanner","advanced-ip-scanner","Latest"),
    @("visioviewer","visioviewer","Latest"),
    @("superputty","superputty","Latest"),
    @("powertoys","powertoys","Latest"),
    @("gnucash","gnucash","Latest"),
    @("abc-update","abc-update","Latest"),
    @("logitechgaming","logitechgaming","Latest"),
    @("bluej","bluej","Latest")
    )

$MediaServerPackages = @( 
    @("bulkrenameutility.install","bulkrenameutility.install","Latest"),
    @("plex","plex","Latest"),
    @("duplicatefilefinder","duplicatefilefinder","Latest")
    )


$SystemRepairPackages = @( 
    @("emsisoft-emergency-kit","emsisoft-emergency-kit","Latest"),
    @("hitmanpro","hitmanpro","Latest"),
    @("aida64extreme","aida64extreme","Latest"),
    @("ultradefrag","ultradefrag","Latest"),
    @("superantispyware","superantispyware","Latest"),
    @("combofix","combofix","Latest"),
    @("kss","kss","Latest"),
    @("malwarebytes","malwarebytes","Latest"),
    @("iobit-malware-fighter","iobit-malware-fighter","Latest"),
    @("housecall.portable","housecall.portable","Latest"),
    @("hijackthis","hijackthis","Latest"),
    @("spybot","spybot","Latest"),
    @("belarcadvisor","belarcadvisor","Latest")
    )


$FortifyOpsPackages = @( 
    @("burp-suite-free-edition","burp-suite-free-edition","Latest"),
    @("vmware-powercli-psmodule","vmware-powercli-psmodule","Latest"),
    @("adexplorer","adexplorer","Latest"),
    @("psscriptanalyzer","psscriptanalyzer","Latest")
    )





# Setup Gaming System



#Needed Packages
#battle.net
#WSL
#Debian
Get-AppxProvisionedPackage -online | ?{$_.DisplayName -notmatch "Store" -and $_.DisplayName -notmatch "Remote" }| %{ Try { Remove-AppxPackage $_.PackageName }catch{echo $_} }

get-appxpackage *3d* -allusers | remove-appxpackage
get-appxpackage *3dbuilder* -allusers | remove-appxpackage
get-appxpackage *alarms* -allusers -allusers | remove-appxpackage
get-appxpackage *appconnector* -allusers | remove-appxpackage
get-appxpackage *appinstaller* -allusers | remove-appxpackage
get-appxpackage *bing* -allusers | remove-appxpackage
get-appxpackage *bingfinance* -allusers | remove-appxpackage
get-appxpackage *bingnews* -allusers | remove-appxpackage
get-appxpackage *bingsports* -allusers | remove-appxpackage
get-appxpackage *bingweather* -allusers | remove-appxpackage
get-appxpackage *calculator* -allusers | remove-appxpackage
get-appxpackage *communicationsapps* -allusers | remove-appxpackage
get-appxpackage *commsphone* -allusers | remove-appxpackage
get-appxpackage *connectivitystore* -allusers | remove-appxpackage
get-appxpackage *camera* -allusers | remove-appxpackage
get-appxpackage *feedback* -allusers | remove-appxpackage
get-appxpackage *getstarted* -allusers | remove-appxpackage
get-appxpackage *holographic* -allusers | remove-appxpackage
get-appxpackage *maps* -allusers | remove-appxpackage
get-appxpackage *messaging* -allusers | remove-appxpackage
get-appxpackage *mspaint* -allusers | remove-appxpackage
get-appxpackage *officehub* -allusers | remove-appxpackage
get-appxpackage *onenote* -allusers | remove-appxpackage
get-appxpackage *oneconnect* -allusers | remove-appxpackage
get-appxpackage *phone* -allusers | remove-appxpackage
get-appxpackage *photos* -allusers | remove-appxpackage
get-appxpackage *skypeapp* -allusers | remove-appxpackage
#get-appxpackage *solitaire* -allusers | remove-appxpackage
get-appxpackage *soundrecorder* -allusers | remove-appxpackage
get-appxpackage *sticky* -allusers | remove-appxpackage
get-appxpackage *sway* -allusers | remove-appxpackage
get-appxpackage *wallet* -allusers | remove-appxpackage
get-appxpackage *windowsphone* -allusers | remove-appxpackage
get-appxpackage *xbox* -allusers | remove-appxpackage
get-appxpackage *zunemusic* -allusers | remove-appxpackage
get-appxpackage *zune* -allusers | remove-appxpackage
get-appxpackage *zunevideo* -allusers | remove-appxpackage
get-appxpackage *people* -allusers | remove-appxpackage

WebpImage
Todos
OfficeLens
RemoteDesktop
Sway
NetworkSpeedTest
GetHelp
ScreenSketch
VP9VideoExtensions
GetStarted
DesktopAppinstaller
HEIFImageExtension
Messaging
MixedReality
OneConnect
Feedbackhub
YourPhone
WebMediaExtensions




#Capsule VPN
start-process ms-windows-store://pdp/?ProductId=9wzdncrdjxtj
#Debian linux
start-process ms-windows-store://pdp/?ProductId=9msvkqc78pk6
#Terminal
start-process ms-windows-store://pdp/?ProductId=9n0dx20hk701
