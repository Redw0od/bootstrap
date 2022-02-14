#Server 2016
POWERCFG -SetActive '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
POWERCFG /SETACVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0
POWERCFG /SETDCVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0
POWERCFG -h off

Install-WindowsFeature RSAT-AD-Tools
Install-WindowsFeature UpdateServices-API

Install-WindowsFeature Windows-Server-Backup

$Services = @("ALG","audiosrv","AudioEndpointBuilder","BITS","defragsvc","DPS","DiagTrack","efs","FDResPub","FontCache","MSiSCSI","sharedaccess","ShellHWDetection","smphost","SNMPTRAP","Spooler","svsvc","SSDPSRV","sstpsvc","swprv","TapiSrv","Themes","upnphost","VSS","WdiServiceHost","WdiSystemHost","WerSvc","WPDBusEnum")
$Services | %{Stop-Service $_ -Force}
$Services | %{Set-Service $_ -StartUpType Disabled}
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

Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
refreshenv

choco install powershell -y
choco install carbon -y
Import-Module Carbon
choco install vim -y --params "'/NoDesktopShortcuts /NoContextMenu /InstallDir:C:\ProgramData\chocolatey\tools'"
refreshenv
New-Item -Path C:\programdata\chocolatey\bin\vim.exe -ItemType SymbolicLink -Value 'C:\Program Files (x86)\vim\vim80\vim.exe'
refreshenv
choco install 7zip -y
New-Item -Path C:\programdata\chocolatey\bin\7z.exe -ItemType SymbolicLink -Value 'C:\Program Files\7-Zip\7z.exe'
choco install sysinternals -y
choco install git -y
refreshenv
New-Item -Path C:\programdata\chocolatey\bin\git.exe -ItemType SymbolicLink -Value 'C:\Program Files\Git\bin\git.exe'
choco install curl -y
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module SQLServer -Force
Import-Module SQLServer
choco install awstools.powershell -y
Install-Module AWSPowerShell -Force
Import-Module AWSPowerShell
Install-Module Pester -Force -SkipPublisherCheck

choco install octopusdeploy.tentacle -y
choco install nsclientplusplus.x64 -y

choco install filebeat -y
choco install winlogbeat -y
choco install metricbeat -y
choco install auditbeat -y
choco install topbeat -y

choco install python -y
choco install golang -y
refreshenv

choco install netfx-4.8-devpack -y

set-mppreference -disablerealtimeMonitoring $true
uninstall-WindowsFeature -Name Windows-Defender


powershell enable-psremoting -force

cscript  c:\windows\system32\scregedit.wsf /AU 4
Start-Service wuauserv
Wuauclt /detectnow 

New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft' -Name 'Internet Explorer' | Out-Null
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer' -Name 'Main' | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main' -Name DisableFirstRunCustomize -PropertyType DWORD -Value '1' | Out-Null
Set-ItemProperty -Path 'HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer' -Name 'NoPreviousVersionsPage' -Value '1'
New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Network' -Name 'NewNetworkWindowOff' | Out-Null


New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' -Name 'DisableBandwidthThrottling' -PropertyType DWORD -Value '1' | Out-Null
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' -Name 'DisableLargeMtu' -PropertyType DWORD -Value '0' | Out-Null
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' -Name 'FileInfoCacheEntriesMax' -PropertyType DWORD -Value '8000' | Out-Null
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' -Name 'DirectoryCacheEntriesMax' -PropertyType DWORD -Value '1000' | Out-Null
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' -Name 'FileNotFoundcacheEntriesMax' -PropertyType DWORD -Value '1' | Out-Null
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' -Name 'MaxCmds' -PropertyType DWORD -Value '8000' | Out-Null
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' -Name 'EnableWsd' -PropertyType DWORD -Value '0' | Out-Null

New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters -Name 'DisableTaskOffload' -PropertyType DWORD -Value '1' | Out-Null

New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense -Name 'AllowStorageSenseGlobal' -PropertyType DWORD -Value '0' | Out-Null

New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MusNotification.exe' -Name 'debugger' -PropertyType reg_sz -Value 'rundll32.exe' | Out-Null



set-timezone -id "Pacific Standard Time"

$elkserver = "bszelk01.hpfod.net"
$product = "zeus"
$service = "admin"
$environment = "build"
$file = "filebeat.yml"
$fileyml = get-content $file
$newyml = ""
$fileyml | %{ `
	if($_ -match '/var/log'){$newyml += "#" + $_ + "`n"}
	elseif($_ -match ' enabled: false'){$newyml += "  enabled: true`n"}
	elseif($_ -match 'c:\\programdata\\elasticsearch'){$newyml += "    - C:\Logs\AdminWeb\*.txt`n"}
	elseif($_ -match 'multiline.pattern'){$newyml += "  multiline.pattern:  '===================='`n"}
	elseif($_ -match 'multiline.negate'){$newyml += "  multiline.negate: true`n"}
	elseif($_ -match 'multiline.match'){$newyml += "  multiline.match: after`n"}
	elseif($_ -match 'setup.kibana'){$newyml += "#" + $_ + "`n"}
	elseif($_ -match 'output.elasticsearch'){$newyml += "#" + $_ + "`n"}
	elseif($_ -match 'localhost:9200'){$newyml +=  "#" + $_ + "`n"}
	elseif($_ -match 'output.logstash'){$newyml += "output.logstash:`n  enabled: true`n"}
	elseif($_ -match 'localhost:5044'){$newyml +=  '  hosts: ["' + $elkserver + ':5044"]`n'}
	elseif($_ -match 'add_cloud_metadata'){$newyml +=  $_ + "`n  - add_labels: `n     labels:`n        product: $product`n        service: $service`n        environment: $environment`n"}
	else{$newyml += $_ + "`n"}
	}
$newyml | set-content $file

$file = "auditbeat.yml"
$audityyml = get-content $file
$newyml = ""
$audityml | %{ `
	if($_ -match 'setup.kibana'){$newyml += "#" + $_ + "`n"}
	elseif($_ -match 'output.elasticsearch'){$newyml += "#" + $_ + "`n"}
	elseif($_ -match 'localhost:9200'){$newyml +=  "#" + $_ + "`n"}
	elseif($_ -match 'output.logstash'){$newyml += "output.logstash:`n  enabled: true`n"}
	elseif($_ -match 'localhost:5044'){$newyml +=  '  hosts: ["' + $elkserver + ':5044"]`n'}
	elseif($_ -match 'add_cloud_metadata'){$newyml +=  $_ + "`n  - add_labels: `n     labels:`n        product: $product`n        service: $service`n        environment: $environment`n"}
	else{$newyml += $_ + "`n"}
	}
$newyml | set-content $file
	

$file = "metricbeat.yml"
$metricyml = get-content $file
$newyml = ""
$metricyml | %{ `
	if($_ -match 'setup.kibana'){$newyml += "#" + $_ + "`n"}
	elseif($_ -match 'output.elasticsearch'){$newyml += "#" + $_ + "`n"}
	elseif($_ -match 'localhost:9200'){$newyml +=  "#" + $_ + "`n"}
	elseif($_ -match 'output.logstash'){$newyml += "output.logstash:`n  enabled: true`n"}
	elseif($_ -match 'localhost:5044'){$newyml +=  '  hosts: ["' + $elkserver + ':5044"]`n'}
	elseif($_ -match 'add_cloud_metadata'){$newyml +=  $_ + "`n  - add_labels: `n     labels:`n        product: $product`n        service: $service`n        environment: $environment`n"}
	else{$newyml += $_ + "`n"}
	}
$newyml | set-content $file


$file = "winlogbeat.yml"
$winlogyml = get-content $file
$newyml = ""
$winlogyml | %{ `
	if($_ -match 'setup.kibana'){$newyml += "#" + $_ + "`n"}
	elseif($_ -match 'output.elasticsearch'){$newyml += "#" + $_ + "`n"}
	elseif($_ -match 'localhost:9200'){$newyml +=  "#" + $_ + "`n"}
	elseif($_ -match 'output.logstash'){$newyml += "output.logstash:`n  enabled: true`n"}
	elseif($_ -match 'localhost:5044'){$newyml +=  '  hosts: ["' + $elkserver + ':5044"]`n'}
	elseif($_ -match 'add_cloud_metadata'){$newyml +=  $_ + "`n  - add_labels: `n     labels:`n        product: $product`n        service: $service`n        environment: $environment`n"}
	else{$newyml += $_ + "`n"}
	}
$newyml | set-content $file


$file = "topbeat.yml"
$topyml = get-content $file
$newyml = ""
$topyml | %{ `
	if($_ -match 'setup.kibana'){$newyml += "#" + $_ + "`n"}
	elseif($_ -match 'elasticsearch:'){$newyml += "#" + $_ + "`n"}
	elseif($_ -match 'localhost:9200'){$newyml +=  "#" + $_ + "`n"}
	elseif($_ -match 'logstash:'){$newyml += "  logstash:`n"}
	elseif($_ -match 'localhost:5044'){$newyml +=  '    hosts: ["' + $elkserver + ':5044"]`n'}
	elseif($_ -match 'add_cloud_metadata'){$newyml +=  $_ + "`n  - add_labels: `n     labels:`n        product: $product`n        service: $service`n        environment: $environment`n"}
	else{$newyml += $_ + "`n"}
	}
$newyml | set-content $file


$NetAdapter = Get-NetAdapter -Physical
$IPStack = Get-NetIpAddress | ?{$_.InterfaceIndex -eq $NetAdapter.ifIndex}
$DNS = $DNSServers.Split(",").Trim()
$IfDNS = Get-DnsClientServerAddresses | ?{$_.InterfaceIndex -eq $NetAdapter.ifIndex -and $_.AddressFamily -eq "2"}


Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”Offload IP Options” -DisplayValue “Disabled” -NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”Offload tagged traffic” -DisplayValue “Disabled” –NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”Offload TCP Options” -DisplayValue “Disabled” –NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”Recv Segment Coalescing (IPv4)” -DisplayValue “Disabled” –NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”Recv Segment Coalescing (IPv6)” -DisplayValue “Disabled” -NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”TCP Checksum Offload (IPv4)” -DisplayValue “Disabled” –NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”TCP Checksum Offload (IPv6)” -DisplayValue “Disabled” -NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”UDP Checksum Offload (IPv4)” -DisplayValue “Disabled” –NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”UDP Checksum Offload (IPv6)” -DisplayValue “Disabled”  –NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”IPv4 TSO Offload” -DisplayValue “Disabled”  –NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”Large Send Offload V2 (IPv4)” -DisplayValue “Disabled” -NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”Large Send Offload V2 (IPv6)” -DisplayValue “Disabled” –NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName "Rx Ring #1 Size" -DisplayValue "4096" -NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName "Rx Ring #2 Size" -DisplayValue "4096" -NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName "Small Rx Buffers" -DisplayValue "8192"
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”Jumbo Packet” -DisplayValue “Jumbo 9000” -NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName "Large Rx Buffers" -DisplayValue "8192"

Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”Offload IP Options” -DisplayValue “Enabled” -NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”Offload tagged traffic” -DisplayValue “Enabled” –NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”Offload TCP Options” -DisplayValue “Enabled” -NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”Recv Segment Coalescing (IPv4)” -DisplayValue “Enabled” –NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”Recv Segment Coalescing (IPv6)” -DisplayValue “Enabled” -NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”TCP Checksum Offload (IPv4)” -DisplayValue “Rx & Tx Enabled” –NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”TCP Checksum Offload (IPv6)” -DisplayValue “Rx & Tx Enabled” -NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”UDP Checksum Offload (IPv4)” -DisplayValue “Rx & Tx Enabled” –NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”UDP Checksum Offload (IPv6)” -DisplayValue “Rx & Tx Enabled” –NoRestart 
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”IPv4 TSO Offload” -DisplayValue “Enabled”  –NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”Jumbo Packet” -DisplayValue “Standard 1500”  –NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”Large Send Offload V2 (IPv4)” -DisplayValue “Enabled” -NoRestart
Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”Large Send Offload V2 (IPv6)” -DisplayValue “Enabled” –NoRestart
Remove-NetAdapterAdvancedProperty "Ethernet0" -RegistryKeyword "MaxRxRing1Length"  -NoRestart
Remove-NetAdapterAdvancedProperty "Ethernet0" -RegistryKeyword "MaxRxRing2Length"  -NoRestart
Remove-NetAdapterAdvancedProperty "Ethernet0" -RegistryKeyword "NumRxBuffersSmall"  -NoRestart

#Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”Large Send Offload V2 (IPv4)” -DisplayValue “Disabled” -NoRestart
#Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”Large Send Offload V2 (IPv6)” -DisplayValue “Disabled” -NoRestart
#Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”IPv4 Checksum Offload” -DisplayValue “Disabled” -NoRestart
#Set-NetAdapterAdvancedProperty "Ethernet0" -DisplayName ”IPv4 Checksum Offload” -DisplayValue “Rx & Tx Enabled” –NoRestart





 Interrupt Moderation
 Maximum number of RSS Proce...
 Maximum number of RSS queues
 Priority / VLAN tag
 Receive Side Scaling
 RSS Base Processor Number
 Speed & Duplex
 Wake on magic packet
 Wake on pattern match
 Enable adaptive rx ring sizing
 Wake-on-LAN
 Rx Ring #1 Size
 Rx Ring #2 Size
 Max Tx Queues
 Tx Ring Size
 MAC Address
 Large Rx Buffers
 Small Rx Buffers
 Receive Throttle
 VLAN ID












netsh int tcp set global chimney=Disabled
netsh int tcp set global autotuninglevel=Disabled
netsh int tcp set supplemental custom congestionprovider=none
netsh int tcp set global ecncapability=Disabled
netsh int ip set global taskoffload=disabled
netsh int tcp set global timestamps=Disabled

netsh int tcp set global chimney=Disabled
netsh int tcp set supplemental custom congestionprovider=none
netsh int ip set global taskoffload=disabled
netsh int tcp set global timestamps=Disabled
netsh int tcp set global autotuninglevel=Normal
netsh int tcp set global ecncapability=Enabled

$NetAdapter = Get-NetAdapter -Physical
$IPStack = Get-NetIpAddress | ?{$_.InterfaceIndex -eq $NetAdapter.ifIndex}
$DNS = $DNSServers.Split(",").Trim()
$IfDNS = Get-DnsClientServerAddress | ?{$_.InterfaceIndex -eq $NetAdapter.ifIndex -and $_.AddressFamily -eq "2"}
$Update = $false


Hey team,  when I'm not doing the SecDevOps thing for Fortify, I'm volunteering as the Scoutmaster for a local scout troop.  The idea of "Be Prepared" is simple but can be daunting.  When you have a spare couple of minutes, I'd recommened reading this emergency preparedness guide from REI. 
https://www.rei.com/learn/expert-advice/emergency-preparedness-basics.html 
At a minimum, I'd recommend printing out the checklist and posting it somewhere easy to find. In the event that you need to evacuate, you'll have reference to keep you focused and calm.