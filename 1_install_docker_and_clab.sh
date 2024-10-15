# NOTE: This script has only been tested on Ubuntu 22.04 LTS
#!/bin/bash
set -euo pipefail



sudo apt install needrestart -y

echo "--- Setting noninteractive and updating repos ---"
export DEBIAN_FRONTEND=noninteractive
echo "\$nrconf{restart} = 'l';" | sudo tee /etc/needrestart/conf.d/90-autorestart.conf > /dev/null
sudo apt-get update

# Install venv
sudo apt install -y python3-venv

# Install net-tools
sudo apt install -y net-tools

# Install Docker and Compose
echo "--- Installing Docker and ContainerLab ---"
if [ -f "setup" ]; then
    rm -v "setup"
fi


# Check if running Ubuntu 24.04
if grep -q "Ubuntu 24.04" /etc/os-release; then
    echo "Ubuntu 24.04 detected. Proceeding with wget..."
	wget https://containerlab.dev/setup
	sed -i 's/^DOCKER_VERSION="[^"]*"/DOCKER_VERSION="5:27.3.1-1~ubuntu.24.10~oracular"/' setup
	cat setup | sudo bash -s "all"
else
    echo "This is not Ubuntu 24.04. trying containerlab install"
	curl -sL https://containerlab.dev/setup | sudo -E bash -s "all"
fi




# Start docker
sudo systemctl start docker

# Get the current username using whoami
current_user=$(whoami)

# Check if the current user is in the docker group
if groups $current_user | grep -q "\bdocker\b"; then
    echo "User $current_user is in the docker group."
else
    echo "User $current_user is NOT in the docker group."
	sudo adduser $current_user docker
fi

echo
echo "--- Creating Docker Network ---"
echo

docker network create --driver=bridge --subnet=${WORKSHOP_SUBNET} autocon-workshop
