#! /bin/sh

#mkdir ./eyemetric-fr
#git clone https://github.com/brightblade42/fr-compose-v2 eyemetric-fr

show_usage() {
	echo "This is the beginning of the Eyemetric-fr install script"
	exit 1
}
#NOTE: currently this is just a list of commands. there's no error handling, validation, or interaction. It's dirty
# main program starts here
echo "installing docker"
apt update -y
apt install -y apt-transport-https ca-certificates curl software-properties-common

echo "adding GPG key for official Docker repo"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "adding official docker repo to apt list"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update -y
echo "are we using the correct docker repo?"
apt-cache policy docker-ce
#this would be a good place to check
#install docker now
apt install -y docker-ce
systemctl status docker

#---------------
# docker-compose 1.29.2 
#----------------
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version 
echo "you can uninstall docker-compose by running sudo rm /usr/local/bin/docker-compose"

#------------------------
# installing nvidia-container-runtime (requires nvidia drivers and nvidia-smi)
#------------------------
curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | tee /etc/apt/sources.list.d/nvidia-container-runtime.list
apt update
apt install -y nvidia-container-runtime
systemctl restart docker
#verify we all good
docker run -it --rm --gpus=all ubuntu nvidia-smi

#-----------------------------------
# now we begin the paravision and FR-service installation
#-----------------------------------
#download our docker-compose files, cpu and gpu
#login to docker so we have access to paravision stuff
#cd to the compose directory
#docker compose up -d 











