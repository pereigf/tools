<#
'Formas de realizar limpeza de disco de sistema operacional (WinSXS, Limpeza de atualizações e funcionalidades obsoletas, Arquivos temporários...):
'------------------------------------------------------------------------------------
'1 - Liberar espaço com tarefa agendada: schtasks.exe /Run /TN "\Microsoft\Windows\Servicing\StartComponentCleanup"
'2 - Liberar espaço com DISM: Dism.exe /online /Cleanup-Image /StartComponentCleanup  
'
#>

schtasks.exe /Run /TN "\Microsoft\Windows\Servicing\StartComponentCleanup"


