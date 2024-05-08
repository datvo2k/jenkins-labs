#!/bin/bash

VAGRANT_HOST_DIR=/mnt/host_machine

sudo apt update -y && sudo apt upgrade -y

# Install Java SDK 11
sudo apt install openjdk-11-jdk default-jre gnupg2 apt-transport-https wget -y

# Long Term Support release
echo "Installing Jenkins and Java"
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins

sudo systemctl start jenkins && sudo systemctl enable jenkins