#!/bin/sh
set -e # make sure any failling command will fail the whole script

##### Set up stackstorm docker compose
echo "--------------------------------------------------------------------------------"
echo "Setting up StackStorm..."
sudo apt-get update
sudo apt-get install -y \
     git \
     build-essential

git clone https://github.com/umccr/st2-docker-umccr.git /opt/st2-docker-umccr

echo "--------------------------------------------------------------------------------"
echo "Preparing for docker-compose"
cd /opt/st2-docker-umccr

# put the local compose file is in place so the docker-compose does not complain about missing resources
ln -sf docker-compose.local.yml docker-compose.yml
make env
##### pre-load the required docker images into the AMI (makes first startup in production faster)
docker-compose pull --quiet --parallel
# make sure the production compose file is in place!
ln -sf docker-compose.prod.yml docker-compose.yml



echo "--------------------------------------------------------------------------------"
echo "Add the docker-compose-up.sh start script"
tee docker-compose-up.sh << END
cd /opt/st2-docker-umccr
docker-compose up -d mongo
docker-compose up -d redis
docker-compose up -d postgres
docker-compose up -d rabbitmq
docker-compose up -d nginx-web
docker-compose up -d nginx-gen
docker-compose up -d nginx-letsencrypt
docker-compose up -d
END

chmod +x docker-compose-up.sh
