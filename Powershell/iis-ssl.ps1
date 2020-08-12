# Variables
$certPath = "c:\certs\ssl.pfx"  
$certPass = "pfxpassword"  
$hostname="azurelab.info"
$websitename="Default Web Site"

  
# Installing SSL certificate to IIS  
$pfx = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2  
$pfx.Import($certPath,$certPass,"Exportable,PersistKeySet")   
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store("WebHosting","LocalMachine")   
$store.Open("ReadWrite")  
$store.Add($pfx)   
$store.Close()   
$certThumbprint = $pfx.Thumbprint  

# Create the SSL binding
New-WebBinding -Name $websitename -Protocol https -Port 443 -HostHeader $hostname
Get-ChildItem cert:\localmachine\WebHosting | New-Item -Path IIS:\SslBindings\!443



