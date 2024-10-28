<#
'Como utilizar:
'------------------------------------------------------------------------------------
'1 - Liberar espaço com tarefa agendada: schtasks.exe /Run /TN "\Microsoft\Windows\Servicing\StartComponentCleanup"
'2 - Liberar espaço com DISM: Dism.exe /online /Cleanup-Image /StartComponentCleanup  
'
#>

schtasks.exe /Run /TN "\Microsoft\Windows\Servicing\StartComponentCleanup"


