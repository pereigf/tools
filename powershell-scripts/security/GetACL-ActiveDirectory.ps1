# Definir a OU alvo
$OU = "AD:OU=.Corporate Users,OU=TEST,DC=TEST,DC=corp" # Substitua pelo DN correto da sua OU

# Obter o ACL da OU
$ACL = Get-ACL -Path $OU

# Permissões para usuários
$userPermissions = @(
    [System.DirectoryServices.ActiveDirectoryRights]::GenericAll,           
    [System.DirectoryServices.ActiveDirectoryRights]::WriteProperty,        
    [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight,       
    [System.DirectoryServices.ActiveDirectoryRights]::WriteProperty        
)

# Permissões para grupos
$groupPermissions = @(
    [System.DirectoryServices.ActiveDirectoryRights]::GenericAll,           
    [System.DirectoryServices.ActiveDirectoryRights]::WriteProperty,        
    [System.DirectoryServices.ActiveDirectoryRights]::WriteDacl            
)


# Listar ACEs que correspondem às permissões específicas e ignorar certos usuários/grupos
$FilteredACES = $ACL.Access | Where-Object {
    ($userPermissions -contains $_.ActiveDirectoryRights -or $groupPermissions -contains $_.ActiveDirectoryRights) -and
    ($_.IdentityReference -notlike "NT AUTHORITY\*" -and
     $_.IdentityReference -notlike "TEST\Domain Admins" -and
     $_.IdentityReference -notlike "TEST\Enterprise Admins")
} | ForEach-Object {
    [PSCustomObject]@{
        Identidade    = $_.IdentityReference
        Direitos      = $_.ActiveDirectoryRights
        ACT           = $_.AccessControlType
        isInherited   = $_.IsInherited
    }

}

# Escrever a variável $OU no início do arquivo
"$OU" | Out-File -FilePath "C:\temp\RelatorioPermissoesUsuariosGrupos_AD1.txt" -Encoding UTF8

# Adicionar as ACEs filtradas ao relatório
$FilteredACES | Format-Table -AutoSize | Out-File -Append -FilePath "C:\temp\RelatorioPermissoesUsuariosGrupos_AD1.txt" -Encoding UTF8
Write-Host "Extraído relatório para C:\temp\RelatorioPermissoesUsuariosGrupos_AD1.txt " -ForegroundColor Cyan