Get-AppxPackage -allusers | ?{$_.IsFramework -eq $false -and $_.SignatureKind -ne "System"} | Remove-AppxPackage
Get-AppxProvisionedPackage -online | ?{$_.DisplayName -notmatch "Store" -and $_.DisplayName -notmatch "Remote" }| %{ 
    Try { Remove-AppxPackage $_.PackageName }catch{echo $_} 
    Try { Remove-AppxProvisionedPackage -online $_.PackageName }catch{echo $_} 
}

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


Write-Host "Install Windows Terminal"
#start-process ms-windows-store://pdp/?ProductId=9n0dx20hk701