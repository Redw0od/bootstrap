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

    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get -y install bash build-essential bzip2 ca-certificates coreutils cpp docker-compose git gnupg golang gzip jq less logrotate make nodejs p7zip packer postgresql-client psutils vim 




# ansible, awscli
    cleanup
}

trap "cleanup; exit 1" 1 2 3 13 15

main "$@"