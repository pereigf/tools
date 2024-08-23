$Username = 'contoso\pereirag'
$Password = 'SuaSenha'
$pass = ConvertTo-SecureString -AsPlainText $Password -Force
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass


$Computers = Get-Content -Path 'C:\Temp\Servers_WSUS.txt'

$command1 = {msiexec.exe /i C:\Temp\PowerShell-7.3.6-win-x64.msi /quiet}


$Count = 0

 

foreach ($computername in $Computers) {

 

    Write-Host "Copiando para " $computername

    $file = "\\SRVWKST02-DC.ambiental.corp\Tools\Powershell 7\PowerShell-7.3.6-win-x64.msi"

    New-PSDrive -Name J -PSProvider FileSystem -Root "\\$computername\C$" -Credential $Cred
    Copy-Item -Path $file -Destination "\\$computername\C$\Temp" -Recurse -Verbose


    Invoke-Command -ComputerName $computers -ScriptBlock $command1 -credential $Cred  -Verbose

}    