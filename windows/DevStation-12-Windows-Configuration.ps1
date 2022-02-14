#Check which OS we're running
#6.3.9600 = 2012 r2
#10.0.14393 = 2016
#10.0.17744 = 2019
$OS = (Get-CimInstance Win32_OperatingSystem).version
Write-Host "Windows Version: $OS"

#Check if Full or Core,  1 for Full, 2 for Core
$Core = (Get-WMIObject Win32_OptionalFeature | where Name -eq 'Server-Gui-Shell').InstallState
if($Core -eq 1){ Write-Host "Standard Windows Installation" }else{Write-Host "Server Core Installation"}

function SetRegistryValue {
    param($Path, $Key="", $Value="", $Type="", [switch]$Create = $false)
    
    $Failed = $False
    try {
        Write-Output "Setting Path $Path Key: $Key"
        $RegKey = Get-Item $Path
        Set-Itemproperty $Regkey.PSPath -Name $Key -Value $Value
    }
    catch {
        Write-Warning "Error updating registery:<$Path> Key:<$Key> Value:<$Value> " -ErrorAction Silently Continue
        $Failed = $true
    }
    if($Failed -and $Create){
        try{
            Write-Output "Creating new key: $Key"
            New-Item -Path (Split-Path -Parent $Path) -Name (Split-Path -Leaf $Path) -Force
            New-ItemProperty -Path $Path -Name $Key -Value $Value -PropertyType $Type
        } catch {
            Write-Warning "Error creating registery:<$Path> Key:<$Key> Value:<$Value> " -ErrorAction Silently Continue
        }
    }
}


#Optimize Services
switch($OS){
    "10.0.17744"{Write-Output "Entered Switch Case for Server 2019"}
    "10.0.14393"{Write-Output "Entered Switch Case for Server 2016"}
    "6.3.9600"{Write-Output "Entered Switch Case for Server 2012"
        Write-Host "`nOptimize EWF (Enhanced Write Filter)" 
        SetRegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OptimalLayout' 'EnableAutoLayout' '0' 'String' -Create
        SetRegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' 'CrashDumpEnabled' '0' 'String' -Create
        SetRegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' 'NtfsDisableLastAccessUpdate' '1' 'String' -Create
        SetRegistryValue 'HKLM:\System\CurrentControlSet\Control\Windows' 'ErrorMode' '2' 'String' -Create
        SetRegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Services\Disk' 'TimeOutValue' '0x000000C8' 'dword' -Create
        SetRegistryValue 'HKLM:\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction' 'Enable' 'N' 'String' -Create
        SetRegistryValue 'HKLM:\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction' 'Enable' 'N' 'String' -Create
        
        
        Write-Host "`nDisabling IE First Run Wizard" 
        Write-Host "<<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>>"
        SetRegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main' 'DisableFirstRunCustomize' '1'  'DWORD' -Create
        SetRegistryValue 'HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer' 'NoPreviousVersionsPage' '1' 'string' -Create
        SetRegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Network' 'NewNetworkWindowOff' '1' 'string' -Create
        
        
        Write-Host "`nOptimize SMB" 
        Write-Host "<<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>>"
        SetRegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' 'DisableBandwidthThrottling' 'DWORD' '1' -Create
        SetRegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' 'DisableLargeMtu' 'DWORD' '0'  -Create
        SetRegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' 'FileInfoCacheEntriesMax' 'DWORD' '8000'  -Create
        SetRegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' 'DirectoryCacheEntriesMax' 'DWORD' '1000'  -Create
        SetRegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' 'FileNotFoundcacheEntriesMax' 'DWORD' '1'  -Create
        SetRegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' 'MaxCmds' 'DWORD' '8000'  -Create
        SetRegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' 'EnableWsd' 'DWORD' '0'  -Create
        
        Write-Host "`nDisable TCP Offload" 
        Write-Host "<<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>>"
        SetRegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' 'DisableTaskOffload' 'DWORD' '1'  -Create
        
        Write-Host "`nDisable Storage Sense" 
        Write-Host "<<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>>"
        SetRegistryValue  'HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense' 'AllowStorageSenseGlobal' 'DWORD' '0'  -Create
        
        Write-Host "`nDisable Install Updates Notification" 
        Write-Host "<<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>>"
        SetRegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MusNotification.exe' 'debugger' 'string' 'rundll32.exe'  -Create
        }
}

Write-Output "Enable remote Symlinking, required for Filer Sharding"
try{
   fsutil behavior set SymlinkEvaluation R2R:1
} catch {
    Write-Warning "Error setting remote Symlinking" -ErrorAction SilentlyContinue
}


Write-Output "Setting Pagefile size to static $PagingFileSize"
try {
    $computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges;
    $computersys.AutomaticManagedPagefile = $False;
    $computersys.Put();
    $pagefile = Get-WmiObject -Query "Select * From Win32_PageFileSetting Where Name like '%pagefile.sys'";
    $pagefile.InitialSize = $PagingFileSize;
    $pagefile.MaximumSize = $PagingFileSize;
    $pagefile.Put();
} catch {
   Write-Warning "Error setting Paging File size"  -ErrorAction SilentlyContinue
}

Write-Output "Setting Activation Server"
if((get-ciminstance softwarelicensingproduct -ComputerName $env:computername -Filter "ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f'" | ?{$_.licensestatus -eq 1 }).licensestatus){
    Write-Output "Windows already activated."
} else {
    Write-Output "Setting KMS Server"
    try{
    & cscript slmgr.vbs -skms psmad05.hpfod.net
    } catch {
        Write-Warning "Error setting KMS server"-ErrorAction SilentlyContinue
    }
    
}

Write-Output "Validating Data Execution Protection settings"
$dep = (bcdedit.exe /enum | ?{$_ -match "nx"} ).Substring("2").Trim()
if($dep -ne "AlwaysOn" -and $dep -ne "OptOut"){
    Write-Output "Correcting DEP to OptOut"
    try {
    & bcdedit.exe /set {current} nx OptOut
    } catch {
        Write-Warning "Failed to set DEP" -ErrorAction SilentlyContinue
    }
}

Write-Output "Optimize Processing for Background Services"
$BGScore =  (get-Itemproperty 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl').Win32PrioritySeparation
if($BGScore -ne "38" ){
    try{
        Write-Output "Setting Process Scheduling to prioritize background services"
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' -Name Win32PrioritySeparation -Value "38"
    } catch {
        Write-Warning "Failed to configure Process Scheduling" -ErrorAction SilentlyContinue
    }
}

Write-Output "Configure OS Recovery Options"
$CrashDump = Get-WmiObject Win32_OSRecoveryConfiguration -EnableAllPrivilege
if($CrashDump.AutoReboot -eq "False"){
    Write-Output "Setting AutoReboot"
    $CrashDump | Set-WmiInstance -Arguments @{AutoReboot="True"}
}
if($CrashDump.DebugInfoType -ne "7"){
    Write-Output "Set Dump Type to Auto"
    $CrashDump | Set-WmiInstance -Arguments @{DebugInfoType=7}
}
if($CrashDump.OverwriteExistingDebugFile -eq "False"){
    Write-Output "Don't overwrite previous dump"
    $CrashDump | Set-WmiInstance -Arguments @{OverwriteExistingDebugFile="False"}
}


Write-Output "Verify RDP Connections"
$RDP =  (get-Itemproperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server').fDenyTSConnections
if($RDP -ne "0" ){
    try{
        Write-Output "Enabling RDP"
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value "0"
    } catch {
        Write-Warning "Failed to enable RDP" -ErrorAction SilentlyContinue
    }
}
$RDPAuth =  (get-Itemproperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp').UserAuthentication
if($RDPAuth -ne "1" ){
    try{
        $credssp = (gci c:\Windows\System32\credssp.dll).VersionInfo.ProductVersion
        if([System.Version]$credssp -ge "6.3.9600.18939"){
            Write-Output "Enabling RDP NLA"
            Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name UserAuthentication -Value "1"
        } else {
            Write-Output "Skipping Enabling NLA. CredSSP not patched."
        }
    } catch {
        Write-Warning "Failed to enable RDP NLA" -ErrorAction SilentlyContinue
    }
}






