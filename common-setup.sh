#!/bin/bash -x
set -euxo pipefail # make sure any failling command will fail the whole script


echo "--------------------------------------------------------------------------------"
echo "Set timezone"
# set to Melbourne local time
sudo rm /etc/localtime
sudo ln -s /usr/share/zoneinfo/Australia/Melbourne /etc/localtime
sudo ls -al /etc/localtime


echo "--------------------------------------------------------------------------------"
echo "Update packages (APT)"
# this delay is crucial for the apt to update properly, without it following install commands will result in package not found errors
while pgrep unattended; do sleep 10; done;
sudo apt-get update
# sudo apt-get -y upgrade

echo "--------------------------------------------------------------------------------"
echo "Install jq"
sudo apt-get install -y jq


echo "--------------------------------------------------------------------------------"
echo "Install awscli"
sudo apt-get install -y python-pip
pip install awscli --upgrade



echo "--------------------------------------------------------------------------------"
echo "Installing s3fs"
# https://github.com/s3fs-fuse/s3fs-fuse
sudo apt-get install -y automake autotools-dev fuse g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config

cd /tmp/
git clone https://github.com/s3fs-fuse/s3fs-fuse.git
cd s3fs-fuse
./autogen.sh
./configure
make
sudo make install

echo "Configuring s3fs"
echo "user_allow_other" | sudo tee -a /etc/fuse.conf



# echo "--------------------------------------------------------------------------------"
# echo "Installing rexray"
# ##### REX-Ray (not needed for the docker plugins)
# # https://rexray.readthedocs.io/en/stable/user-guide/installation/
# cd /tmp/
# curl -sSL https://rexray.io/install | sh -s -- stable


echo "--------------------------------------------------------------------------------"
# Allows *public* members on UMCCR org to SSH to our AMIs
ORG="UMCCR"

echo "Fetching GitHub SSH keys for $ORG members..."
org_ssh_keys=`curl -s https://api.github.com/orgs/$ORG/members | jq -r .[].html_url | sed 's/$/.keys/'`
for ssh_key in $org_ssh_keys
do
	wget $ssh_key -O - >> ~/.ssh/authorized_keys
done
echo "All SSH keys from $ORG added to the AMI's ~/.ssh/authorized_keys"
