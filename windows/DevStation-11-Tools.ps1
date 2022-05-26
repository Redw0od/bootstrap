Write-Output ""
Write-Output "####################################"
Write-Output "Installing Tools"
Write-Output "####################################"

$ErrorActionPreference = 'silentlycontinue'
$Packages = @()
$WingetPackages = @(
    @("Go","GoLang.Go","Latest"),
    @("python","Python.Python.3","Latest"),
    @("Chrome","Google.Chrome","Latest"),
    @("notepad\+\+","Notepad++.Notepad++","Latest"),
    @("FoxitReader","Foxit.FoxitReader","Latest"),
    @("firefox","Mozilla.Firefox","Latest"),
    @("ccleaner","Piriform.CCleaner","Latest"),
    @("filezilla","TimKosse.FileZilla.Client","Latest"),
    @("dropbox","Dropbox.Dropbox","Latest"),
    @("VisualStudioCode","Microsoft.VisualStudioCode","Latest"),
    @("NodeJS","OpenJS.NodeJS","Latest"),
    @("openvpn","OpenVPNTechnologies.OpenVPNConnect","Latest"),
    @("openconnect-gui","openconnect-gui","Latest"),
    @("lens","Mirantis.Lens","Latest"),
    @("slack","SlackTechnologies.Slack","Latest"),
    @("Teams","Microsoft.Teams","Latest"),
    @("Google.Drive","Google.Drive","Latest"),
    @("lastpass","LogMeIn.LastPass","Latest"),
    @("windbg","9PGJGD53TN86","Latest"),
    @("Office","Microsoft.Office","Latest"),
    @("OneDrive","Microsoft.OneDrive","Latest"),
    @("AngryIPScanner","angryziber.AngryIPScanner","Latest"),
    @("PowerToys","Microsoft.PowerToys","Latest"),
    @("GnuPG","GnuPG.GnuPG","Latest"),
    @("Docker","Docker.DockerDesktop","Latest"),
    @("wiztree","AntibodySoftware.WizTree","Latest"),
    @("anyconnect","9WZDNCRDJ8LH","Latest"))

if ( Get-Command winget ){
    ForEach($Package in $WingetPackages){
    
        $PackageId = $Package[0]
        $PackageName = $Package[1]
        $PackageVersion = $Package[2]
            
        if ( ! (winget list | ?{$_ -match $PackageId} ) ){
            if ( $PackageVersion -ne "Latest") {
               # Write-Output "winget install --accept-source-agreements --accept-package-agreements $PackageName -v $PackageVersion"
                & winget install --accept-source-agreements --accept-package-agreements $PackageName -v $PackageVersion
            }
            else {
               # Write-Output "winget install --accept-source-agreements --accept-package-agreements $PackageName"
                & winget install --accept-source-agreements --accept-package-agreements $PackageName
            }
        }
    }
} 
elseif( Get-Command choco) {
    $Packages = @( 
        @("golang","golang","Latest"),
        @("python","python","Latest"),
        @("googlechrome","googlechrome","Latest"),
        @("notepadplusplus.install","notepadplusplus.install","Latest"),
        @("foxitreader","foxitreader","Latest"),
        @("firefox","firefox","Latest"),
        @("ccleaner","ccleaner","Latest"),
        @("filezilla","filezilla","Latest"),
        @("dropbox","dropbox","Latest"),
        @("vscode","vscode","Latest"),
        @("nodejs.install","nodejs.install","Latest"),
        @("openvpn","openvpn","Latest"),
        @("openconnect-gui","openconnect-gui","Latest"),
        @("lens","lens","Latest"),
        @("slack","slack","Latest"),
        @("microsoft-teams.install","microsoft-teams.install","Latest"),
        @("googledrive","googledrive","Latest"),
        @("lastpass","lastpass","Latest"),
        @("windbg","windbg","Latest"),
        @("office365business","office365business","Latest"),
        @("advanced-ip-scanner","advanced-ip-scanner","Latest"),
        @("powertoys","powertoys","Latest"),
        @("gpg4win","gpg4win","Latest"),
        @("wiztree","wiztree","Latest")
        )
}
exit
$Packages += @( 
    @("eksctl","eksctl","Latest"),
    @("vscode-kubernetes-tools","vscode-kubernetes-tools","Latest"),
    @("vscode-cloud-code","vscode-cloud-code","Latest"),
    @("vscode-go","vscode-go","Latest"),
    @("vscode-ansible","vscode-ansible","Latest"),
    @("vscode-yaml","vscode-yaml","Latest"),
    @("vscode-gitlens","vscode-gitlens","Latest"),
    @("vscode-python","vscode-python","Latest"),
    @("vscode-powershell","vscode-powershells","Latest"),
    @("vscode-java","vscode-java","Latest"),
    @("vscode-intellicode","vscode-intellicode","Latest"),
    @("vscode-beautify","vscode-beautify","Latest"),
    @("terraform","terraform","Latest"),
    @("terragrunt","terragrunt","Latest"),
    @("terraformer","terraformer","Latest"),
    @("docker-engine","docker-engine","Latest"),
    @("docker-cli","docker-cli","Latest"),
    @("docker-compose","docker-compose","Latest"),
    @("lastpass-chrome","lastpass-chrome","Latest"),
    @("ublockorigin-chrome","ublockorigin-chrome","Latest"),
    @("ublockorigin-firefox","ublockorigin-firefox","Latest"),
    @("packer","packer","Latest")
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
    }
    
}





