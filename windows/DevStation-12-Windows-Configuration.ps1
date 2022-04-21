
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
    "6.3.9600"{Write-Output "Entered Switch Case for Server 2012"}
    "10.0.19044"{Write-Output "Entered Switch Case for Windows 10"
        Write-Host "`nOptimize EWF (Enhanced Write Filter)" 
        SetRegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OptimalLayout' 'EnableAutoLayout' '0' 'String' -Create
        SetRegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' 'CrashDumpEnabled' '0' 'String' -Create
        SetRegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' 'NtfsDisableLastAccessUpdate' '1' 'String' -Create
        SetRegistryValue 'HKLM:\System\CurrentControlSet\Control\Windows' 'ErrorMode' '2' 'String' -Create
        SetRegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Services\Disk' 'TimeOutValue' '0x000000C8' 'dword' -Create
        SetRegistryValue 'HKLM:\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction' 'Enable' 'N' 'String' -Create
        SetRegistryValue 'HKLM:\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction' 'Enable' 'N' 'String' -Create
        
                
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






