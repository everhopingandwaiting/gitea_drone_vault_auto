#! /bin/bash

# base
export BASE_PATH=/root/aliroot/ci_cd

ls ${BASE_PATH} || mkdir -p ${BASE_PATH}
cd ${BASE_PATH}
source .env

# gitea app.ini setup
gitea_domain=${SYS__ADDR} # get from .env

gitea_protocal=http

## env

export MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
# gitea 
export GITEA_DOMAIN_PORT=10081
export GITEA_SERVER=${gitea_protocal}://${gitea_domain}:10081
export DRONE_GITEA_CLIENT_ID=${DRONE_GITEA_CLIENT_ID}
export DRONE_GITEA_CLIENT_SECRET=${DRONE_GITEA_CLIENT_SECRET}
# drone
export DRONE_SERVER_HOST=${SYS_DRONE_ADDR}
export DRONE_SERVER_PROTO=http

export DRONE_UI_PASSWORD=${DRONE_UI_PASSWORD}
export DRONE_UI_USERNAME=${DRONE_UI_USERNAME}

# vault
export VAULT_TOKEN=${VAULT_TOKEN}


## end

# timezone config
echo "Asia/Shanghai" > /etc/timezone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

mkdir -p ${BASE_PATH}/vault/config
cp -r vault_conf/* ${BASE_PATH}/vault/config
mkdir -p ${BASE_PATH}/gitea/gitea
cp -r gitea_custom_config/* ${BASE_PATH}/gitea/gitea
# replace app.ini fields
sed -i "s/#gitea_domain#/${gitea_domain}/g" ${BASE_PATH}/gitea/gitea/conf/app.ini
sed -i "s/#gitea_domain_port#/${GITEA_DOMAIN_PORT}/g" ${BASE_PATH}/gitea/gitea/conf/app.ini
sed -i "s/#gitea_protocal#/${gitea_protocal}/g" ${BASE_PATH}/gitea/gitea/conf/app.ini
sed -i "s/#mysql_root_password#/${MYSQL_ROOT_PASSWORD}/g" ${BASE_PATH}/gitea/gitea/conf/app.ini

docker network prune -f
docker system prune -f
systemctl start docker.service


#  before run docker-compose, print config first
echo "#######################start##########################"
docker-compose config
echo "########################end#########################"
#  docker-compose pull --include-deps
# go go go ko
docker-compose up --force-recreate  --remove-orphans -d
docker-compose up  --remove-orphans -d
docker-compose logs -t --tail="1000"
# or 
# docker stack deploy -c docker-compose.yml gitea_all

docker ps


# unseal vault
curl --request PUT  --data "@secret_document/payload_vault.json"  http://127.0.0.1:8200/v1/sys/unseal

# curl  --header "X-Vault-Token: ${VAULT_TOKEN}" http://127.0.0.1:8200/v1/sys/seal -X PUT