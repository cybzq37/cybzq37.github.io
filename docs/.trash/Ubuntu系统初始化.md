#### 登录配置
```bash
vim /etc/ssh/sshd_config
#---start---
PermitRootLogin yes
PubkeyAuthentication yes
#---end-----

systemctl restart sshd


```

#### 服务器环境检查
```bash
# 系统版本检查
lsb_release -a  
cat /etc/os-release  
uname -a  

# cpu检查

# 磁盘检查
lsblk  
df -h  
fdisk -l

# 内存检查
free -lh

# step1 检查机器ip和mac地址
ip a
ifconfig

# 检查机器码信息
dmidecode -s system-serial-number

# 关闭防火墙
systemctl stop firewalld.service
systemctl disable firewalld.service

# 关闭AppArmor安全模块
systemctl stop apparmor
systemctl disable apparmor
```

#### 磁盘格式化
```bash
# 执行
apt update
apt install xfsprogs

# step1 进入磁盘分区
fdisk /dev/sdb

# step2 编辑分区，依次输入 n p enter enter w 命令

# step3 格式化
mkfs.xfs /dev/sdb1

# step4 挂载
mkdir -pv /minedata
mount /dev/vdb1 /minedata
echo "/dev/vdb1 /minedata ext4 defaults 0 0 " >> /etc/fstab

# step5 检查挂载
mount a
```

#### 网络环境配置
```bash
# 定义系统的hostname（主机名）
vim /etc/hostname
#---begin---
master.svc.cn
#---end-----

# 编辑host
vim /etc/hosts
#---begin---
171.17.171.21 master master.svc.cn
#---end-----

# 临时配置DNS
vim /etc/resolv.conf
#---begin---
nameserver 8.8.8.8
nameserver 1.1.1.1
#---end-----

# 【centos7】配置ip地址，一般只需要修改下面几项
vim /etc/sysconfig/network-scripts/ifcfg-ens33
#---begin---
BOOTPROTO="static"
ONBOOT="yes"
IPADDR="171.17.171.21"
PREFIX="24"
GATEWAY="171.17.171.2"
NETMASK="255.255.255.0"
DNS1="8.8.8.8"
DNS2="114.114.114.114"
IPV6_PRIVACY="no"
#---end-----

systemctl restart network
```

>**网络配置说明**  
>`/etc/hostname` 定义系统的“主机名”（hostname），仅包含一个主机名字符串，例如 `master.svc.cn`，系统启动时读取此文件，将该名称设为本机主机名，供 `hostname` 命令、系统提示符、日志等使用。  
>`/etc/hosts` 提供本地的*主机名*到*IP*的映射，使系统在不依赖 DNS 的情况下解析主机名。例如 `171.17.171.21 master master.svc.cn` 本机通过名字（如 `master` 或 `master.svc.cn`）访问 `171.17.171.21`。  
>`/etc/resolv.conf`中的配置不会持久保存，再重启后会被网络配置覆盖。

#### 免密登录配置
```bash
# step1
mkdir -p ~/.ssh && chmod 700 ~/.ssh
# step2 执行下面命令，连续敲入三个回车，会在/root/.ssh生成id_rsa和id_rsa.pub
# 也可以手动上传已有的id_rsa和id_rsa.pub
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# step3 执行ssh-copy-id
ssh-copy-id node1
# or
ssh-copy-id -i ~/.ssh/id_rsa.pub node1
# or
cat id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# step4 复制到其他主机
ssh-copy-id -i ~/.ssh/id_rsa.pub node2
ssh-copy-id -i ~/.ssh/id_rsa.pub node3
# or
scp /root/.ssh/authorized_keys node2:/root/.ssh
scp /root/.ssh/authorized_keys node2:/root/.ssh
```

>也可以使用一键配置脚本，需要安装 `yum install sshpass` ![[运维/脚本/ssh_key_push.sh]]

>`cat id_rsa.pub >> ~/.ssh/authorized_keys` 与 `ssh-copy-id` 的区别  
>ssh-copy-id 只将当前用户的 `id_rsa.pub` **追加**到远程的 `authorized_keys`，自动检查公钥是否存在，**不会重复添加**，会创建 `.ssh` 目录、设置 `600` 和 `700` 权限，**确保能登录**，更安全。

#### 本地yum配置
```bash
# step1 挂载
mount /root/CentOS-7-x86_64-DVD-2009.iso /mnt

# step2 备份
mkdir /etc/yum.repos.d/bak  
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak  

# step3 编辑新的repo
vim /etc/yum.repos.d/CentOS-Base.repo

#---begin---
[base]  
name=CentOS-7.6  
baseurl=file:///mnt  
gpgcheck=0  
enable=1  
#---end-----

# step4 更新
yum clean all  
yum makecache  
```


​  ### 时钟同步

方式一：通过网络方式同步
```bash
# step1 启动定时任务
crontab -e
# step2 随后在输入界面键入以下内容
*/1 * * * * /usr/sbin/ntpdate -u ntp4.aliyun.com;
```
方式二：通过某一台机器进行同步
```bash
# step1 
# master节点安装服务
yum -y install ntp
systemctl start  ntpd
# 关闭chrony,Chrony是NTP的另一种实现
systemctl disable chrony
# 设置ntp服务为开机启动
systemctl enable ntpd

# step2 
# 编辑master节点的 /etc/ntp.conf
vim /etc/ntp.conf
# 在文件中添加如下内容(授权192.168.88.0-192.168.88.255网段上的所有机器可以从这台机器上查询和同步时间)
restrict 171.17.171.0 mask 255.255.255.0 nomodify notrap
# 注释掉下面四行内容:(集群在局域网中，不使用其他互联网上的时间)
#server  0.centos.pool.ntp.org
#server  1.centos.pool.ntp.org
#server  2.centos.pool.ntp.org
#server  3.centos.pool.ntp.org
# 去掉以下内容的注释，如果没有这两行注释，那就自己添加上(当该节点丢失网络连接，依然可以采用本地时间作为时间服务器为集群中的其他节点提供时间同步)
server   127.127.1.0
fudge    127.127.1.0  stratum  10

# step3
# 配置以下内容，保证BIOS与系统时间同步
vim /etc/sysconfig/ntpd
#---begin---
OPTIONS="-g"
SYNC_HWLOCK=yes
#---end-----

# 重启服务
systemctl restart  ntpd  


# step4
# 其他机器与mater节点时间同步
crontab -e
# 随后输入
*/1 * * * * /usr/sbin/ntpdate 171.17.171.17

```

![[assets/etc_ntp_conf.png]]

#### 环境变量配置
```bash
# step1 可在/etc/environment中配置全局环境变量
vim /etc/environment

# step2 立即生效
echo "source /etc/environment" >> /etc/profile  
source /etc/profile

# step3 当前用户配置
vim ~/.bashrc
```  
​  
#### jdk环境配置
```bash
tar -zxvf jdk-8u251-linux-x64.tar.gz -C /opt

vim /etc/environment
#---begin---
#set java environment 
JAVA_HOME=/opt/jdk1.8.0_251
CLASSPATH=.:$JAVA_HOME/lib
PATH=$JAVA_HOME/bin:$PATH
export JAVA_HOME CLASSPATH PATH
#---end-----

source /etc/profile
```

#### 后台文件传输
```bawh
setsid rsync -av --progress *.tar.gz root@10.200.101.28:/data/minedata/nginx_data >> rsync.log 2>&1
```
定时任务
```bash
crontab -e
*/5 * * * * rsync -avzP --delete user@remote:/source/dir/ /local/target/dir/ > /dev/null 2>&1
```



alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}"'  
alias dlg="f() { docker logs -f --tail=\"\$1\" \"\$2\"; }; f"


#循环导入镜像  
for i in `ls *.tar` ; do docker load -i $i ; done
