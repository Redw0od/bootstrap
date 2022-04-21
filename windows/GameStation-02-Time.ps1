Write-Output ""
Write-Output "####################################"
Write-Output "Configuring Time Service"
Write-Output "####################################"

$TimeZoneSetting = "Pacific Standard Time"

# Configure Time Service to Domain Server
Write-Output "Stopping Time Service"
net stop w32time
Write-Output "Configuring Time Service"
w32tm /config /syncfromflags:DOMHIER /update
Write-Output "Starting Time Service"
net start w32time
Write-Output "Syncing Time Service"
w32tm /resync

Write-Output "Setting Time Zone"
tzutil /s $TimeZoneSetting
Write-Output "Finished"