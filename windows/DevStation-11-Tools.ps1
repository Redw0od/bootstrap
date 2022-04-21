Write-Output ""
Write-Output "####################################"
Write-Output "Installing Tools"
Write-Output "####################################"

$ErrorActionPreference = 'silentlycontinue'
$Packages = @()
if ( Get-Command winget ){
    if ( ! (Get-Command go) ){
        & winget install GoLang.Go
    }
    if ( ! (Get-Command python) ){
        & winget install Python.Python.3
    }
    if ( ! (Get-Command chrome ) ){
        & winget install Google.Chrome
    }
    if ( ! (Get-Command Notepadplusplus ) ){
        & winget install Notepad++.Notepad++
    }
    if ( ! (Get-Command Foxit) ){
        & winget install Foxit.FoxitReader
    }
    if ( ! (Get-Command Firefox ) ){
        & winget install Mozilla.Firefox
    }
    if ( ! (Get-Command CCleaner) ){
        & winget install Piriform.CCleaner
    }
    if ( ! (Get-Command TimKosse.FileZilla.Client) ){
        & winget install filezilla
    }
    if ( ! (Get-Command Dropbox ) ){
        & winget install Dropbox.Dropbox
    }
    if ( ! (Get-Command code ) ){
        & winget install Microsoft.VisualStudioCode
    }
    if ( ! (Get-Command node ) ){
        & winget install OpenJS.NodeJS
    }
    if ( ! (Get-Command openvpn ) ){
        & winget install OpenVPNTechnologies.OpenVPNConnect
    }
    if ( ! (Get-Command Lens ) ){
        & winget install Mirantis.Lens
    }
    if ( ! (Get-Command Slack ) ){
        & winget install SlackTechnologies.Slack
    }
    if ( ! (Get-Command Teams ) ){
        & winget install Microsoft.Teams
    }
    if ( ! (Get-Command Google.Drive ) ){
        & winget install Google.Drive
    }
    if ( ! (Get-Command LastPass ) ){
        & winget install LogMeIn.LastPass
    }
    if ( ! (Get-Command windbg ) ){
        & winget install 9PGJGD53TN86
    }
    if ( ! (Get-Command outlook ) ){
        & winget install Microsoft.Office
    }
    if ( ! (Get-Command onedrive ) ){
        & winget install Microsoft.OneDrive
    }
    if ( ! (Get-Command AngryIPScanner ) ){
        & winget install angryziber.AngryIPScanner
    }
    if ( ! (Get-Command Microsoft.PowerToys ) ){
        & winget install Microsoft.PowerToys
    }
    if ( ! (Get-Command GPG ) ){
        & winget install GnuPG.GnuPG
    }
    if ( ! (Get-Command wiztree ) ){
        & winget install AntibodySoftware.WizTree
    }
    if ( ! (Get-Command docker ) ){
        & winget install Docker.DockerDesktop
    }
} 
elseif( Get-Command choco -erroraction 'silentlycontinue') {
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
        @("vim","vim","Latest"),
        @("wiztree","wiztree","Latest")
        )
}

$Packages = @( 
    @("eksctl","eksctl","Latest"),
    @("openssh","openssh","Latest"),
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





