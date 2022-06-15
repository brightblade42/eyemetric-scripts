#! /bin/sh

#mkdir ./eyemetric-fr
#git clone https://github.com/brightblade42/fr-compose-v2 eyemetric-fr

datadb_ver="v0.92" #this may become a problem. seems easy to go out of sync. 

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
git clone https://github.com/brightblade42/compose-fr.git
cd compose-fr/gpu
docker login -u eyemetricfr -p 19darkangel84

#run the dbvol container, copy out the tar files, unpack them to the /var/lib/docker/volumes directory with names
#that match what docker expects for our actual containers
# gpu_pvdb-data, gpu_safr-db
dvol=/var/lib/docker/volumes
docker run -d --rm --name dbdata eyemetricfr/dbdata:$datadb_ver
docker cp dbdata:/safr_pgdata.gz.tar $dvol 
tar -xsvf $dvol/safr_pgdata.gz.tar -C $dvol
mv $dvol/safr_pgdata $dvol/gpu_safr-db
docker cp dbdata:/pvdb_pgdata.gz.tar $dvol
tar -xsvf $dvol/pvdb_pgdata.gz.tar -C $dvol
mv $dvol/pvdb_pgdata $dvol/gpu_pv-data
rm -r $dvol/*.tar
 
docker stop dbdata

docker-compose --env-file=../.env up -d

