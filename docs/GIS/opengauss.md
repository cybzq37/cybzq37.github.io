opengauss

```bash
# 1.拉取镜像
docker pull enmotech/opengauss

# 2.开启opengauss数据库服务
docker run --name opengauss \
    --privileged=true -d \
    -e GS_USERNAME=gaussdb \
    -e GS_PASSWORD=**************@*** \
    -p 5432:5432 \
    enmotech/opengauss:latest
```

```bash

# 1. 进入运行的Docker容器
docker exec -it opengauss /bin/bash

# 2. 设置环境变量
export GAUSSHOME=/usr/local/opengauss
export PATH=$GAUSSHOME/bin:$GAUSSHOME:$GAUSSHOME/lib:$PATH
export LD_LIBRARY_PATH=$GAUSSHOME/lib:$LD_LIBRARY_PATH
export DATADIR='/var/lib/opengauss/data'

# 3. 使用gsql登陆opengauss数据库
gsql -U gaussdb -W **************@*** -d postgres -p 5432

# 4. 创建test_db数据库
CREATE DATABASE test_db WITH ENCODING 'UTF8' template = template0;

# 5. 重新加载OpenGauss数据库
gs_ctl reload -D $DATADIR

```


```bash

ALTER USER postgres SYSADMIN;

```


