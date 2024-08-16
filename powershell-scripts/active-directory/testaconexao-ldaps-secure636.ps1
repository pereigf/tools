Function Test-LDAPConnection {

               
    $DCs = Get-ADComputer -Filter * -SearchBase "OU=Domain Controllers, DC=teste, DC=corp"
    #OU VOCÊ PODE ADICIONAR OS SERVIDORES EM UM ARQUIVO DE TEXTO
    #$DCs = Get-Content "C:\Temp\ListaDomainControllers.txt"
    $Port = "636" 
      
        $ErrorActionPreference = "Stop"
        $Results = @()
        Try{ 
            Import-Module ActiveDirectory -ErrorAction Stop
        }
        Catch{
            $_.Exception.Message
            Break
        } 
             
        ForEach($DC in $DCs){
            $DC =$DC.trim
            Write-Verbose "Processing $DC"
            Try{
                $DCName = (Get-ADDomainController -Identity $DC).hostname
            }
            Catch{
                $_.Exception.Message
                Continue
            }
      
            If($DCName -ne $Null){  
                Try{
                    $Connection = [adsi]"LDAP://$($DCName):$Port"
                }
                Catch{
                    $ExcMessage = $_.Exception.Message
                    throw "Error: Failed to make LDAP connection. Exception: $ExcMessage"
                }
      
                If ($Connection.Path) {
                    $Object = New-Object PSObject -Property ([ordered]@{ 
                           
                        DC                = $DC
                        Port              = $Port
                        Path              = $Connection.Path
                    })
      
                    $Results += $Object
                }         
            }
        }
      
        If($Results){
            Return $Results
        }
    
    }