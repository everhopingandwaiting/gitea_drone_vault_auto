#! /bin/bash

# base
export BASE_PATH=/root/aliroot/ci_cd

ls ${BASE_PATH} || mkdir -p ${BASE_PATH}
cd ${BASE_PATH}
source .env
# kjfkf
# gitea app.ini setup
gitea_domain=${SYS__ADDR} # get from .env

## env

export MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
# gitea
export GITEA_SERVER=${GITEA_PROTOCAL}://${GITEA_SERVER_HOST}
export DRONE_GITEA_CLIENT_ID=${DRONE_GITEA_CLIENT_ID}
export DRONE_GITEA_CLIENT_SECRET=${DRONE_GITEA_CLIENT_SECRET}
# drone
export DRONE_SERVER_HOST=${SYS_DRONE_ADDR}
export DRONE_SERVER_PROTO=${GITEA_PROTOCAL}

if [ ${DB_TYPE} = mysql ]; then
    export DRONE_DATABASE_DATASOURCE="root:${MYSQL_ROOT_PASSWORD}@tcp(mysql-server:3306)/drone?parseTime=true"
else
    export DRONE_DATABASE_DATASOURCE=/data/database.sqlite
fi

export DRONE_UI_PASSWORD=${DRONE_UI_PASSWORD}
export DRONE_UI_USERNAME=${DRONE_UI_USERNAME}

# vault
export VAULT_TOKEN=${VAULT_TOKEN}

DB_TYPE=${DB_TYPE}

## end

# timezone config
echo "Asia/Shanghai" >/etc/timezone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

mkdir -p ${BASE_PATH}/vault/config
cp -r vault_conf/* ${BASE_PATH}/vault/config
mkdir -p ${BASE_PATH}/gitea/gitea
cp -r gitea_custom_config/* ${BASE_PATH}/gitea/gitea
# replace app.ini fields
sed -i "s/#gitea_domain#/${gitea_domain}/g" ${BASE_PATH}/gitea/gitea/conf/app.ini
sed -i "s/#gitea_domain_port#/${GITEA_DOMAIN_PORT}/g" ${BASE_PATH}/gitea/gitea/conf/app.ini
sed -i "s/#gitea_protocal#/${GITEA_PROTOCAL}/g" ${BASE_PATH}/gitea/gitea/conf/app.ini
sed -i "s/#mysql_root_password#/${MYSQL_ROOT_PASSWORD}/g" ${BASE_PATH}/gitea/gitea/conf/app.ini
sed -i "s/#db_type#/${DB_TYPE}/g" ${BASE_PATH}/gitea/gitea/conf/app.ini

sed -i "s?#gitea_root_url#?$GITEA_SERVER?g" ${BASE_PATH}/gitea/gitea/conf/app.ini

sed -i "s/need_to_replace_ip/${gitea_domain}/g" $(grep need_to_replace_ip -rl ${BASE_PATH}/gitea)

rm -fr ${BASE_PATH}/gitea/gitea/indexers

docker network prune -f
docker system prune -f
systemctl start docker.service

#  before run docker-compose, print config first
echo "#######################start##########################"
docker-compose config
echo "########################end#########################"

echo DB_TYPE:${DB_TYPE}
# go go go ko
ARGS_COMPOSE=
if [ ${DB_TYPE} = mysql ]; then
    ARGS_COMPOSE="-f docker-compose-mysql.yml -f docker-compose.yml"
else
    ARGS_COMPOSE="-f docker-compose.yml"
fi
docker-compose $ARGS_COMPOSE pull --include-deps
if [ -n "$1" -a "$1" = "swarm" ]; then
    echo "swarm start"
    docker-compose $ARGS_COMPOSE config | docker stack deploy -c - --prune --with-registry-auth gitea_all
    docker node ls
    docker stack services gitea_all

else
    docker-compose $ARGS_COMPOSE up --force-recreate --remove-orphans -d
    docker-compose scale ssh-runner=2 docker-runner=2
    docker-compose logs -t --tail="1000"
fi

docker ps
docker images

# unseal vault
curl --request PUT --data "@secret_document/payload_vault.json" http://127.0.0.1:8200/v1/sys/unseal

# curl  --header "X-Vault-Token: ${VAULT_TOKEN}" http://127.0.0.1:8200/v1/sys/seal -X PUT
