[![Build Status](https://drone.jyao.xyz/api/badges/jyao/gitea_drone_vault_auto/status.svg)](https://drone.jyao.xyz/jyao/gitea_drone_vault_auto)

### gitea + drone + drone-runner + redis + mysql + vault + 自动部署脚本


* .env 中配置 `SYS__ADDR=  和 SYS_DRONE_ADDR= `环境变量
* 按需改动`BASE_PATH`路径为自己需要的
* 安装`docker`和 `docker-compose`
* 启动 ： `sh start.sh`

## 启动前在当前目录下 新建 `.env`文件， 填写如下变量配置
 ```bash

SYS__ADDR=
GITEA_PROTOCAL=
GITEA_DOMAIN_PORT=
SYS_DRONE_ADDR=
GITEA_SERVER=
DRONE_GITEA_CLIENT_ID
DRONE_GITEA_CLIENT_SECRET=
DRONE_UI_PASSWORD=
DRONE_UI_USERNAME=
VAULT_TOKEN=
MYSQL_ROOT_PASSWORD=
DB_TYPE=
 ```


> 启动容器列表：


```
➜  ~ docker ps
CONTAINER ID        IMAGE                       COMMAND                  CREATED             STATUS              PORTS
             NAMES
8329d5db7773        drone/drone                 "/bin/drone-server"      2 hours ago         Up 2 hours                     80/tcp
             drone-server
5b8e19842a17        drone/drone-runner-ssh      "/bin/drone-runner-s…"   2 hours ago         Up 2 hours                     3000/tcp                                     ssh-runner
544e844ca172        drone/drone-runner-docker   "/bin/drone-runner-d…"   2 hours ago         Up 2 hours                     3000/tcp                                     docker-runner
0af1d2410585        mysql                       "docker-entrypoint.s…"   2 hours ago         Up 2 hours                     3306/tcp                           mysql-server
41b16c8ec691        gitea/gitea                 "/usr/bin/entrypoint…"   2 hours ago         Up 2 hours                     3000/tcp,tcp   gitea-server
3df042d8040b        drone/vault                 "/bin/drone-vault"       2 hours ago         Up 2 hours                        3000/tcp                                                    drone-vault
d48d5ca29ba7        vault                       "docker-entrypoint.s…"   2 hours ago         Up 2 hours                             8200/tcp                                      vault-server
974fc5f87f72        nginx                       "nginx -g 'daemon of…"   2 hours ago         Up 2 hours                         443/tcp                    nginx-server
8f05528d8173        adminer                     "entrypoint.sh docke…"   2 hours ago         Up 2 hours                 8080/tcp                                     adminer-server                                 9d436f801f18        redis                       "docker-entrypoint.s…"   2 hours ago         Up 2 hours          6379/tcp                                                    redis-server
d52a6ea7d2b4        registry                    "/entrypoint.sh /etc…"   2 hours ago         Up 2 hours                     5000/tcp                        docker-registry      
```

### 注意：

docker-compose 构建需要必须环境变量，执行前要么直接 `sh start.sh`启动，或者先如下操作：

```bash

# base
export BASE_PATH=/root/aliroot/ci_cd

ls ${BASE_PATH} || mkdir -p ${BASE_PATH}
cd ${BASE_PATH}
source .env

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

if [ ${DB_TYPE} = mysql ]
then
export DRONE_DATABASE_DATASOURCE="root:${MYSQL_ROOT_PASSWORD}@tcp(mysql-server:3306)/drone?parseTime=true"
else 
export DRONE_DATABASE_DATASOURCE=/data/database.sqlite
echo no such db
fi

export DRONE_UI_PASSWORD=${DRONE_UI_PASSWORD}
export DRONE_UI_USERNAME=${DRONE_UI_USERNAME}

# vault
export VAULT_TOKEN=${VAULT_TOKEN}

DB_TYPE=${DB_TYPE}

## end
```


### 获取自签名证书
 ```bash
 
 openssl req -newkey rsa:4096 -nodes -keyout domain.key -x509 -days 300 -out domain.crt

 ```

 ## 启动时docker daomon 停止

 > 可能由于某个容器发生未知错误，需手动 `docker rm -f 容器ID`


