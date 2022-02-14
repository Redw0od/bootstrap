#Check which OS we're running
#6.3.9600 = 2012 r2
#10.0.14393 = 2016
#10.0.17744 = 2019
$OS = (Get-CimInstance Win32_OperatingSystem).version
Write-Host "Windows Version: $OS"

#Check if Full or Core,  1 for Full, 2 for Core
$Core = (Get-WMIObject Win32_OptionalFeature | where Name -eq 'Server-Gui-Shell').InstallState
if($Core -eq 1){ Write-Host "Standard Windows Installation" }else{Write-Host "Server Core Installation"}

Install-WindowsFeature RSAT-AD-Tools
Install-WindowsFeature UpdateServices-API

Install-WindowsFeature Windows-Server-Backup

$Services = @("ALG","audiosrv","AudioEndpointBuilder","BITS","defragsvc","DPS","DiagTrack","efs","FDResPub","FontCache","MSiSCSI","sharedaccess","ShellHWDetection","smphost","SNMPTRAP","Spooler","svsvc","SSDPSRV","sstpsvc","swprv","TapiSrv","Themes","upnphost","VSS","WdiServiceHost","WdiSystemHost","WerSvc","WPDBusEnum")
$Services | %{Stop-Service $_ -Force}
$Services | %{Set-Service $_ -StartUpType Disabled}
sc.exe config wuauserv type= own










