

## 备份还原

### 逻辑备份

```bash
#pg备份还原整个数据库实例
pg_dumpall -U postgres --clean -f all_databases_backup.sql
psql -U postgres -f all_databases_backup.sql
```

### 物理备份

```bash
#　-D /backup_directory/：备份文件存储目录 -Ft：备份为 tar 格式 -z：压缩备份 -P：显示进度
pg_basebackup -U postgres -D /backup_directory/ -Ft -z -P

pg_basebackup -U postgres -D /root/backup/ -Ft -z -P -p 16430

# 还原
docker stop tsdb
rm -rf /data/tsdb/data/*
tar -xzf base.tar.gz -C /data/tsdb/data/
tar -xzf pg_wal.tar.gz -C /data/tsdb/data/pg_wal
```

### 单个数据库备份还原

```bash
#pg备份数据库
pg_dump -U postgres -F c -d mydb -f mydb_backup.dump
#还原数据库
createdb -U postgres newdb
pg_restore -U postgres -d newdb mydb_backup.dump
```

### 主从配置

```bash
# 主库创建流复制账户
docker exec -it postgres /bin/bash
su postgres
psql
CREATE ROLE replica login replication encrypted password 'replica';  #新建流复制用户
\du     #查看新建的账户情况
\q      #退出数据库
exit    #退出postgres容器账户，然后再执行一次exit退出容器  

# 主库配置修改
# 先修改pg_hba.conf文件，在配置中新增流复制主机ip，并配置trust访问主库免密，新增如下信息
host   replication      replica       从库IP/32          trust
# 保存退出后，再修改postgresql.conf配置，修改配置中关于流复制的配置信息，修改内容如下（如果有部分内容在配置文件中没有，可以不用修改，不用纠结）
listen_addresses = '*'   # 监听所有IP
archive_mode = on  # 允许归档
archive_command = '/bin/date' # 用该命令来归档logfile segment,这里取消归档。
wal_level = replica #开启热备
max_wal_senders = 32 # 这个设置了可以最多有几个流复制连接，差不多有几个从，就设置几个
wal_keep_size = 16  # 或你需要保留的大小
wal_sender_timeout = 60s #设置流复制主机发送数据的超时时间
max_connections = 200 #这个设置要注意下，从库的max_connections必须要大于主库的
#修改完成后，重启主库容器；

# 从库配置
docker exec -it postgres
/bin/bash
su postgres
cd /var/lib/postgresql/data
rm -rf ./*
# 备份主机数据到 repl 文件夹，此处需要输入密码：replica
pg_basebackup -R -D /bitnami/postgresql/repl -Fp -Xs -v -P -h 10.200.101.28 -p 5432 -U replica
# 重建slave容器，删除原有文件夹，将 repl 重命名为 slave
docker rm -f slave
cd /data/psql/
rm -rf slave
mv repl slave
cd /data/psql/slave
# 3. 查看配置信息
# postgresql.auto.conf 将含有复制所需信息
cat postgresql.auto.conf

primary_conninfo = 'user=repuser password=123456 channel_binding=prefer host=172.18.0.101 port=5432 sslmode=prefer sslcompression=0 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any'

```

### ssh配置
客户端配置
 `~/.ssh/config` 文件配置 
 -  `ServerAliveInterval 60`：每60秒发送一次心跳包。  
 -  `ServerAliveCountMax 3`：如果连续3次没有响应，则自动断开连接。  
```
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
```
服务器配置
```
ClientAliveInterval 60
ClientAliveCountMax 3
```