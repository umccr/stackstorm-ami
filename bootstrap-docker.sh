#!/bin/sh

echo "--------------------------------------------------------------------------------"
echo "Installing docker"
# follow instructions from Docker docs
# https://docs.docker.com/install/linux/docker-ce/ubuntu/
sudo apt-get remove docker docker-engine

sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update

# sudo apt-get -y upgrade # may cause hang due to interactive promt of grub update

sudo apt-get install -y docker-ce

# basic post install config
# https://docs.docker.com/install/linux/linux-postinstall/
sudo groupadd docker
sudo usermod -aG docker ubuntu
sudo systemctl enable docker
# test the install
docker --version

echo "--------------------------------------------------------------------------------"
echo "Installing docker-compose"
# https://docs.docker.com/compose/install
# curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
curl -L https://github.com/docker/compose/releases/download/1.20.0-rc2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
# test the install
docker-compose --version


# disabled until the rexray issue is solved
# echo "--------------------------------------------------------------------------------"
# echo "Installing docker rexray EBS plugin"
# install docker driver plugin for REX-Ray (to mount AWS storage devices via docker volumes)
# https://rexray.readthedocs.io/en/stable/user-guide/schedulers/docker/plug-ins/aws/#simple-storage-service
# NOTE: Installation requires AWS access granted via stackstorm_instance_profile.
#       This profile is maintained and generated by Terraform. If this step fails, check
#       that the profile is in place and grants sufficient permissions.
# NOTE: Change to create separate profile for packer, which is stable and independent of Terraform setup?
#       Will allow restriction of Terraform profile to specific buckets.
# echo "Installing rexray S3 plugin"
# docker plugin install --grant-all-permissions rexray/s3fs S3FS_REGION=ap-southeast-2
# docker plugin install --grant-all-permissions rexray/ebs EBS_REGION=ap-southeast-2
