Write-Output ""
Write-Output "####################################"
Write-Output "Configuring Power Settings"
Write-Output "####################################"

POWERCFG -SetActive '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
POWERCFG /SETACVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0
POWERCFG /SETDCVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0
POWERCFG -h off