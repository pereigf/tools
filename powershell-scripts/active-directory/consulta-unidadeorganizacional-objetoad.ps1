# Importar o módulo do Active Directory
Import-Module ActiveDirectory

# Nome do grupo de segurança
$groupName = "NomeDoGrupoNoAD"

# Obter todos os membros do grupo de segurança
$groupMembers = Get-ADGroupMember -Identity $groupName

# Lista para armazenar resultados
$resultados = @()

# Iterar sobre cada membro do grupo
foreach ($computer in $groupMembers) {

   Get-ADComputer -Identity $computer -Properties DistinguishedName | Select-Object -ExpandProperty DistinguishedName

    }

# Exibir resultados
$resultados | Format-Table -AutoSize