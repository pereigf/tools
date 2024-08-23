$Targets = Get-Content -Path 'C:\Temp\Servers_WSUS_History.txt'


Invoke-Command ($Targets) {

If ($null -eq (Get-Module -Name PSWindowsUpdate -ListAvailable) ) {

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module PSWindowsUpdate -Force
Import-Module PSWindowsUpdate
Enable-WURemoting 


}
}