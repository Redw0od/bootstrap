#!/usr/bin/env bash
readonly username="$(whoami)"
readonly sudo_tmp="/tmp/${username}-setup"
readonly sudo_file="/etc/sudoers.d/${username}-setup"

cleanup() {
    sudo rm "${sudo_file}"
}

main() {
    
    if [[ $(id -u) == "0" ]]; then
        echo "Detected Root Privileges, its recommended to not run as root."
        readonly rootuser="true"
    else
        readonly rootuser="false"
    fi

    if [[ $rootuser == "false" ]]; then
        echo "Defaults:${username} timestamp_timeout=7200" > "${sudo_tmp}"
        sudo chown root:root "${sudo_tmp}"
        sudo mv "${sudo_tmp}" "${sudo_file}"
    fi

    ls /etc/sudoers.d

    wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O- | sudo apt-key add -
    echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" | sudo tee /etc/apt/sources.list.d/postgresql.list
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get -y install bash build-essential bzip2 ca-certificates coreutils cpp docker-compose git gnupg golang gzip jq less logrotate make nodejs p7zip packer postgresql-client-10 psutils vim 

    # Install Brew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/mike/.bashrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    brew install gcc 
    brew install terraform terragrunt helm eksctl kops vault libpq bfg nvm npm docker

    sudo usermod -aG docker $USER

    # import vault certs
    echo -n "Enter the folder location of CA certificates: "
    read cafolder
    sudo cp $cafolder /usr/local/share/ca-certificates
    sudo update-ca-certificates
# ansible, awscli
    cleanup
}

trap "cleanup; exit 1" 1 2 3 13 15

main "$@"