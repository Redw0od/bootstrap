Write-Output ""
Write-Output "####################################"
Write-Output "Optimizing Scheduled Tasks"
Write-Output "####################################"

$OS = (Get-CimInstance Win32_OperatingSystem).version
Write-Host "Windows Version: $OS"

#Check if Full or Core,  1 for Full, 2 for Core
#$Core = (Get-WMIObject Win32_OptionalFeature | where Name -eq 'Server-Gui-Shell').InstallState
#if($Core -eq 1){ Write-Host "Standard Windows Installation" }else{Write-Host "Server Core Installation"}

$DisableTask = @()
$DisablePath = @()
$EnableTask = @()
$EnablePath = @()

Function SetTask {
    param($Task, $Action, [switch]$Path = $false)
    if($Path){
        try{
            $Tasks = get-scheduledtask | ?{$_.TaskPath -match $Task}
        } catch {
            Write-Output "Error finding tasks: $Task"
        }
        try{
            if($Action -eq "Disable"){
                Write-Output "Disabling Tasks: $Task"
                $Tasks | Disable-ScheduledTask | Out-Null
            } else {
                Write-Output "Enabling Tasks: $Task"
                $Tasks | Enable-ScheduledTask | Out-Null
            }
        } catch {
            Write-Output "Error updating $Task to $Action"
        }
    } else {
        try{
            if($Action -eq "Disable"){
                Write-Output "Disabling Task: $Task"
                Get-ScheduledTask $Task | Disable-ScheduledTask | Out-Null
            } else {
                Write-Output "Enabling Task: $Task"
                Get-ScheduledTask $Task | Enable-ScheduledTask | Out-Null
            }
        } catch {
            Write-Output "Error updating $Task to $Action"
        }
    }
}


switch($OS){
    "6.3.9600" {
        Write-Output "Disabling Unnecessary Tasks for Windows Server 2012"
        $DisableTask = @(
            'Optimize Start*',
            'SmartScreenSpecific',
            'Proxy',
            'ProactiveScan',
            'ScheduledDefrag',
            'SQM data sender',
            'GatherNetworkInfo',
            'MobilityManager',
            'LPRemove',
            'Idle Maintenance',
            'SystemSoundsService',
            'AnalyzeSystem',
            'ServerManager',
            'SpaceAgentTask',
            'MsCtfMonitor',
            'CacheTask',
            'Tpm-Maintenance',
            'uPnpHostConfig',
            'QueueReporting',
            'WSTask'
            )
        $DisablePath = @(
            'Application Experience',
            'Customer Experience',
            'Software',
            'WindowsUpdate'
            )
        $EnableTask = @(
            'SynchronizeTime',
            'SystemTask',
            'UserTask',
            'BindingWorkItemQueueHandler',
            'RegIdleBackup',
            'CleanUpOldPerfLogs',
            'StartComponentCleanup',
            'CreateObjectTask',
            'Configuration',
            'ResolutionHost',
            'BfeOnServiceStartTypeChange',
            'Storage Tiers Management Initialization',
            'Maintenance Configurator',
            'Manual Maintenance',
            'Regular Maintenance'
            )
        $EnablePath = @(
            'Data Integrity Scan'
            )
    }
    "10.0.19044" {
        Write-Output "Disabling Unnecessary Tasks for Windows 10.0.19044"
        $DisableTask = @(
            'MicrosoftEdgeUpdateTaskMachine*',
            'DmClient*',
            'FODCleanupTask',
            'MapsToastTask',
            'WiFiTask',
            'FamilySafetyMonitor',
            'FamilySafetyRefreshTask',
            'ForceSynchronizeTime',
            'SynchronizeTime*',
            'Windows Defender Scheduled Scan',
            'XblGameSaveTask',
            'SynchronizeTime',
            'Proxy',
            'ProactiveScan',
            'ScheduledDefrag',
            'GatherNetworkInfo',
            'MobilityManager',
            'LPRemove',0
            'SpaceAgentTask',
            'MsCtfMonitor',
            'CacheTask',
            'uPnpHostConfig',
            'QueueReporting'
            )

    }
}


# Disable 'Optimize Start*' and lose text entry in windows search

$DisableTask | %{ SetTask $_ "Disable" }
$DisablePath | %{ SetTask $_ "Disable" -Path }
$EnableTask | %{ SetTask $_ "Enable" }
$EnablePath | %{ SetTask $_ "Enable" -Path }

