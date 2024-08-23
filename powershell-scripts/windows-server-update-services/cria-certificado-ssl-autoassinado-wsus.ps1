# 1. Create a self-signed certificate using the FQDN
    # Setup the stage dynamically for the $FQDN based on if the system is a member of a domain or is just in a workgroup.
    $DNSHostName = (Get-CimInstance win32_computersystem -Verbose:$False).DNSHostName
    $DNSDomainName = $( if ((Get-CimInstance -Class Win32_ComputerSystem -Verbose:$False).PartOfDomain -eq 'True') { (Get-CimInstance win32_computersystem -Verbose:$False).Domain } )
    $FQDN = "$DNSHostName$( if ((Get-CimInstance -Class Win32_ComputerSystem -Verbose:$False).PartOfDomain -eq 'True') { ".$DNSDomainName" } )".ToLower()
    # Create the hash table for splatting
    $SelfSignedHT = @{
     DnsName = $FQDN
     CertStoreLocation = "Cert:\LocalMachine\My"
    }
    # Create the self-signed certificate and set a variable to hold the object
    $SelfSignedWSUSCertificate = New-SelfSignedCertificate @SelfSignedHT
 
# 2. Export its public key to the local user's Documents folder
    Export-Certificate -Cert $SelfSignedWSUSCertificate -Type CERT -FilePath "$([Environment]::GetFolderPath("MyDocuments"))\SelfSignedWSUSCertificate.cer"
     
# 3. Import the public key in the Trusted Root Certificate Authorities store
    Import-Certificate -FilePath "$([Environment]::GetFolderPath("MyDocuments"))\SelfSignedWSUSCertificate.cer" -CertStoreLocation Cert:\LocalMachine\Root
 
# 4. Select this certificate in the SSL bindings
    Get-WebBinding -Protocol https
    $SelfSignedWSUSCertificate | New-Item IIS:\SslBindings\0.0.0.0!8531
 
# 5. Require SSL for the following virtual roots only:
    'SimpleAuthWebService','DSSAuthWebService',
    'ServerSyncWebService','APIRemoting30',
    'ClientWebService' | ForEach-Object {
        Set-WebConfigurationProperty -Filter 'system.webserver/security/access' -Location "WSUS Administration/$($_)" -Name sslFlags -Value 8
    }
 
# 6. Switch WSUS to SSL
    & 'C:\Program Files\Update Services\Tools\WsusUtil.exe' configuressl $($FQDN)