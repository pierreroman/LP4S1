Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/pierreroman/LP4S1/master/Storage-migration-demo/DSC/WindowsAdminCenterDscConfiguration.ps1' -OutFile 'WindowsAdminCenterDscConfiguration.ps1'
Install-Module -Name PSDscResources
. .\WindowsAdminCenterDscConfiguration.ps1
WindowsAdminCenter
Start-DscConfiguration -Path .\WindowsAdminCenter\ -ComputerName localhost -Wait -Verbose