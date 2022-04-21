
Install-WindowsFeature RSAT-AD-Tools
Install-WindowsFeature UpdateServices-API

Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
sc.exe config wuauserv type= own

get-scheduledtask "BfeOnServiceStartTypeChange" | Disable-ScheduledTask
get-scheduledtask "Consolidator" | Disable-ScheduledTask
get-scheduledtask "ProactiveScan" | Disable-ScheduledTask
get-scheduledtask "QueueReporting" | Disable-ScheduledTask
get-scheduledtask "RegIdleBackup" | Disable-ScheduledTask
get-scheduledtask "ResolutionHost" | Disable-ScheduledTask
get-scheduledtask "ScheduledDefrag" | Disable-ScheduledTask
get-scheduledtask "StartComponentCleanup" | Disable-ScheduledTask
get-scheduledtask "TPM-Maintenance" | Disable-ScheduledTask
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Autochk\Proxy" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Ras\MobilityManager" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\UPnP\UPnPHostConfig" | Out-Null

Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name CrashDumpEnabled -Value '0'
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name NtfsDisableLastAccessUpdate -Value '1'
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Windows' -Name ErrorMode -Value '2'
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Disk' -Name TimeOutValue -Value '0x000000C8'
New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction' -Name Enable -Force
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction' -Name Enable -Value 'N'

$Packages = @( 
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
    @("openssh","openssh","Latest"),
    @("ccleaner","ccleaner","Latest"),
    @("foxitreader","foxitreader","Latest"),
    @("filezilla","filezilla","Latest"),
    @("dotnetfx","dotnetfx","Latest"),
    @("dropbox","dropbox","Latest"),
    @("vscode","vscode","Latest"),
    @("spotify","spotify","Latest"),
    @("steam","steam","Latest"),
    @("slack","slack","Latest"),
    @("googledrive","googledrive","Latest"),
    @("cpu-z.install","cpu-z.install","Latest"),
    @("lastpass","lastpass","Latest"),
    @("lastpass-chrome","lastpass-chrome","Latest"),
    @("ublockorigin-chrome","ublockorigin-chrome","Latest"),
    @("ublockorigin-firefox","ublockorigin-firefox","Latest"),
    @("winbox","winbox","Latest"),
    @("nvidia-display-driver","nvidia-display-driver","Latest"),
    @("discord.install","discord.install","Latest"),
    @("hwinfo.install","hwinfo.install","Latest"),
    @("windbg","windbg","Latest"),
    @("wiztree","wiztree","Latest"),
    @("advanced-ip-scanner","advanced-ip-scanner","Latest"),
    @("intel-dsa","intel-dsa","Latest"),
    @("powertoys","powertoys","Latest"),
    @("aida64extreme","aida64extreme","Latest"),
    @("logitechgaming","logitechgaming","Latest"),
    @("epicgameslauncher","epicgameslauncher","Latest")
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


    $chocoArgs = @("-y")
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

