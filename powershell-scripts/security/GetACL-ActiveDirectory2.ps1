# Define the path to the file or directory
$path = "AD:OU=.Corporate Users,OU=TEST,DC=TEST,DC=corp"

$acl = Get-Acl -Path $path

$acl | Format-List | Out-File -FilePath "C:\temp\RelatorioPermissoesUsuariosGrupos_AD2.txt"
