Invoke-WebRequest -Uri 'https://gist.githubusercontent.com/PlagueHO/e8120e1cc01b447d084322eb2ad14c95/raw/2aff9e1a8d94cdb6f8a7409874a3bdbfcf234f8e/WindowsAdminCenterDscConfiguration.ps1' -OutFile 'WindowsAdminCenterDscConfiguration.ps1'
Install-Module -Name PSDscResources
. .\WindowsAdminCenterDscConfiguration.ps1
WindowsAdminCenter
Start-DscConfiguration -Path .\WindowsAdminCenter\ -ComputerName localhost -Wait -Verbose