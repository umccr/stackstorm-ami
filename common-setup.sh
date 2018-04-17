#!/bin/bash -x
set -euxo pipefail # make sure any failling command will fail the whole script


echo "--------------------------------------------------------------------------------"
echo "Set timezone"
# set to Melbourne local time
sudo rm /etc/localtime
sudo ln -s /usr/share/zoneinfo/Australia/Melbourne /etc/localtime
sudo ls -al /etc/localtime


echo "--------------------------------------------------------------------------------"
echo "Configure SSH"
echo "GatewayPorts yes" | sudo tee -a /etc/ssh/sshd_config


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


# currently not used
# echo "--------------------------------------------------------------------------------"
# echo "Installing s3fs"
# # https://github.com/s3fs-fuse/s3fs-fuse
# sudo apt-get install -y automake autotools-dev fuse g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config
#
# cd /tmp/
# git clone https://github.com/s3fs-fuse/s3fs-fuse.git
# cd s3fs-fuse
# ./autogen.sh
# ./configure
# make
# sudo make install
#
# echo "Configuring s3fs"
# echo "user_allow_other" | sudo tee -a /etc/fuse.conf



# echo "--------------------------------------------------------------------------------"
# echo "Installing rexray"
# ##### REX-Ray (not needed for the docker plugins)
# # https://rexray.readthedocs.io/en/stable/user-guide/installation/
# cd /tmp/
# curl -sSL https://rexray.io/install | sh -s -- stable


echo "--------------------------------------------------------------------------------"
echo "Adding SSH public keys"
# Allows *public* members on UMCCR org to SSH to our AMIs
ORG="UMCCR"

echo "Fetching GitHub SSH keys for $ORG members..."
org_ssh_keys=`curl -s https://api.github.com/orgs/$ORG/members | jq -r .[].html_url | sed 's/$/.keys/'`
for ssh_key in $org_ssh_keys
do
	wget $ssh_key -O - >> ~/.ssh/authorized_keys
done
echo "All SSH keys from $ORG added to the AMI's ~/.ssh/authorized_keys"

echo "Adding key for novastor"
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6DPL4+ORF/cXZ9qhQryQyZhKl6piPKUmkoHeLPJY80z87+zpWTilY/fWwgixouzbBdvmEMVtF0SrzPPCJAydX/kut+g8pagm4nLqskyybMpuWnrvJvYe/rEUbuLsQ6uxpLevc0rjnwcJTKlRQgOU95IG+/9MgRnp6vL+ETcRpFuKfhbrKEH8W50fb5ev+z2JNKE2VZSeWnwDOE4Ux4qo1PyAKtv118k5iZ0gCxrX5dwch3yETKgqAxzN+MXSlFlRwAwfBfhBGu349mGlloy0lKMpQhlGC2cNS5jGj+wzGWUi308V0HFBOiR+Z/zilQqWLvQgZ6pSZsY0/rfQaGk5T limsadmin@5180-novastor01.mdhs.unimelb.edu.au" >> ~/.ssh/authorized_keys
