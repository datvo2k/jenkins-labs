#!/bin/bash

green_msg() {
    tput setaf 2
    echo "[*] ----- $1"
    tput sgr0
}

# add gpg key
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -

# add docker repo
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"

echo 
green_msg "Install docker"
echo
sleep 0.5

# install docker
sudo apt-get update && sudo apt-get install docker-ce -y

sudo usermod -aG docker "${USER}"
sudo chmod 666 /var/run/docker.sock
sudo systemctl restart docker.service

echo 
green_msg "Done!"
echo
sleep 0.5
