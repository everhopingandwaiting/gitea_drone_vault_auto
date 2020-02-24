[![Build Status](https://drone.jyao.xyz/api/badges/jyao/ci_cd/status.svg)](https://drone.jyao.xyz/jyao/ci_cd)

### gitea + drone + drone-runner + redis + mysql + vault + 自动部署脚本


* .env 中配置 `SYS__ADDR=  和 SYS_DRONE_ADDR= `环境变量
* 按需改动`BASE_PATH`路径为自己需要的
* 安装`docker`和 `docker-compose`
* 启动 ： `sh start.sh`

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
d52a6ea7d2b4        registry                    "/entrypoint.sh /etc…"   2 hours ago         Up 2 hours                     5000/tcp                                      docker-registry      
```

### 注意：

docker-compose 构建需要必须环境变量，执行前要么直接 `sh start.sh`启动，或者先如下操作：

```bash

source .env

# gitea app.ini setup
gitea_domain=${SYS__ADDR} # get from .env

gitea_protocal=https

## env
# base
export BASE_PATH=/root/aliroot/ci_cd
export MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
# gitea 
export GITEA_DOMAIN_PORT=10081
export GITEA_SERVER=${gitea_protocal}://${gitea_domain}
export DRONE_GITEA_CLIENT_ID=049b6079-084c-41c7-8b49-21a5f581bd4d
export DRONE_GITEA_CLIENT_SECRET=1PHyGHGOfgn1jvDVf_TVxvvdEb5n1pC5q8x4gCP1mjA=
# drone
export DRONE_SERVER_HOST=${SYS_DRONE_ADDR}
export DRONE_SERVER_PROTO=https

export DRONE_UI_PASSWORD=${DRONE_UI_PASSWORD}
export DRONE_UI_USERNAME=${DRONE_UI_USERNAME}

# vault
export VAULT_TOKEN=${VAULT_TOKEN}
```