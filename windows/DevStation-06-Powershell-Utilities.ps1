Write-Output ""
Write-Output "####################################"
Write-Output "Installing Powershell Utilities"
Write-Output "####################################"

$ErrorActionPreference = 'silentlycontinue'
$Packages = @()
if ( Get-Command winget ){
    if ( ! (Get-Command aws) ){
        & winget install Amazon.AWSCLI
    }
    if ( ! (Get-Command session-manager-plugin) ){
        & winget install Amazon.SessionManagerPlugin
    }
    if ( ! (Get-Command sam ) ){
        & winget install Amazon.SAM-CLI
    }
    if ( ! (Get-Command 'C:\Program Files\7-Zip\7z' ) ){
        & winget install 7zip.7zip
    }
    if ( ! (Get-Command git) ){
        & winget install Git.Git
    }
    if ( ! (Get-Command OhMyPosh ) ){
        & winget install JanDeDobbeleer.OhMyPosh 
    }
    if ( ! (Get-Command psexec) ){
        & winget install 9P7KNL5RWT25 --accept-package-agreements
    }
    if ( ! (Get-Command 'C:\Program Files\Vim\vim82\vim') ){
        & winget install vim.vim
    }
} 
elseif( Get-Command choco -erroraction 'silentlycontinue') {
    $Packages = @( 
        @("awscli","awscli","Latest"),
        @("awscli-session-manager","awscli-session-manager","Latest"),
        @("awssamcli","awssamcli","Latest"),
        @("7zip","7zip","Latest"),
        @("git","git","Latest"),
        @("oh-my-posh","oh-my-posh","Latest"),
        @("sysinternals","sysinternals","Latest"),
        @("vim","vim","Latest")
        )
}


$Packages += @( 
    @("Carbon","Carbon","Latest"),
    @("curl","curl","Latest")
    )

& choco feature disable -n=showDownloadProgress


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
        "vim" {$chocoArgs += (' --params "/NoDesktopShortcuts /NoContextMenu /InstallDir:' + $Env:ChocolateyToolsLocation + '"')}
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
        } 
        & refreshenv
    } else {
        & choco install $ChocolateyPackageId $($chocoArgs)
    }

    switch($ChocolateyPackageId){
        "Carbon" {Import-Module Carbon}
        "AWSTools.Powershell" { Install-Module AWSPowerShell -Force; Import-Module AWSPowerShell }
    }    
    
}


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