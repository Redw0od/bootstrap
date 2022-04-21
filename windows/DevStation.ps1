powershell.exe ".\DevStation-01-WinRM.ps1"
powershell.exe ".\DevStation-02-Time.ps1"
powershell.exe ".\DevStation-03-Package-Managers.ps1"
powershell.exe ".\DevStation-04-dotNet.ps1"
powershell.exe ".\DevStation-05-Powershell.ps1"
powershell.exe ".\DevStation-06-Powershell-Utilities.ps1"
#powershell.exe ".\DevStation-07-Power.ps1"
powershell.exe ".\DevStation-08-Scheduled-Tasks.ps1"
powershell.exe ".\DevStation-09-Services.ps1"
powershell.exe ".\DevStation-10-Windows-Features.ps1"
powershell.exe ".\DevStation-11-Tools.ps1"
powershell.exe ".\DevStation-12-Windows-Configuration.ps1"
#powershell.exe ".\DevStation-13-Certificates.ps1"
#powershell.exe ".\DevStation-13-Network.ps1"

# Setup Lastpass
# Install uBlock Origin
# Configure OpenVPN
#    https://vpn.respond-software.com

# LINUX
# Install git openssh vim
sudo apt-get install -y golang nodejs awscli git docker-compose jq p7zip packer ansible python2.7 python-pip build-essential postgresql-client 

### Install psql and pg_dump
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O- | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" | sudo tee /etc/apt/sources.list.d/postgresql.list
sudo apt-get update -y
sudo apt-get install -y postgresql-client-10


# Install brew
brew install gcc 
brew install terraform terragrunt helm eksctl kops vault libpq bfg nvm npm expect

mkdir ~/go
mkdir ~/tmp
cd ~/tmp
wget https://go.dev/dl/go1.18.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.18.linux-amd64.tar.gz
export PATH=/usr/local/go/bin:$PATH
go install github.com/pcarrier/gauth@latest
# install ~/.config/gauth.csv
mkdir ~/.config
cp /mnt/c/Users/mikes/Desktop/gauth.csv ~/.config/