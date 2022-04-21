Write-Output ""
Write-Output "####################################"
Write-Output "Disabling Unnecessary Services"
Write-Output "####################################"

$Services = @(
    "defragsvc",
    "TabletInputService",
    "WbioSrvc",
    "WdNisSvc",
    "WinDefend")

$Services | %{Stop-Service $_ -Force}
$Services | %{Set-Service $_ -StartUpType Disabled}
sc.exe config wuauserv type= own




uninstall-WindowsFeature -Name Windows-Defender






