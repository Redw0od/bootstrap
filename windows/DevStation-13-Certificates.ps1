#Install Certificates

if(-Not (Test-Certificate -Cert cert:\LocalMachine\root\7058F03C9972205361782C918C219473CCE853F0)){
    #Import-Certificate -FilePath "\\hpfod.net\NETLOGON\Certificates\PsmCerts01-2039.cer" -CertStoreLocation cert:\LocalMachine\root
}



#get-certificate -Template "FOD-ComputerRDP" -DnsName (hostname) -SubjectName "CN=$(hostname)" -CertStoreLocation cert:\LocalMachine\My
#gci cert:\localmachine\my | ?{$_.Subject -match "RDP"} | export-certificate -FilePath "C:\Windows\Temp\RDP.cer"
#Import-Certificate -FilePath "C:\Windows\Temp\RDP.cer" -CertStoreLocation "cert:\LocalMachine\Remote Desktop"

