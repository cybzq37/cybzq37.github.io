#### 常用命令
```bash
# 查看可用发行版
wsl --list --online 或 wsl -l -o
# 查看已安装发行版
wsl --list --verbose 或 wsl -l -v
# 安装发行版
wsl --install -d <发行版名称>
# 关机
wsl --shutdown
```

#### 迁移命令
```bash
wsl --shutdown
wsl --export Ubuntu-22.04 D:\\wsl2\\images\\Ubuntu-22.04.tar
wsl --unregister Ubuntu-22.04
wsl --import Ubuntu-22.04 D:\\wsl2\\data D:\\wsl2\\images\\Ubuntu-22.04.tar
```

#### 配置文件
地址栏输入 `%UserProfile%` 回车，在该目录下创建一个名为.wslconfig的文件：  
```bash
[wsl2]
memory=32GB
swap=8GB
swapfile=D:\\wsl2\\data\\swap.vhdx
processors=16
#localhostForwarding=false    # 镜像网络配置模式下，转发无效

[experimental]
autoMemoryReclaim=gradual    # 开启自动回收内存，可在 gradual, dropcache, disabled 之间选择
networkingMode=mirrored      # 开启镜像网络
dnsTunneling=true            # 开启 DNS Tunneling
firewall=false                # 开启 Windows 防火墙
autoProxy=true               # 开启自动同步代理
sparseVhd=true               # 开启自动释放 WSL2 虚拟硬盘空间
```

#### 文件存储
在存储 WSL 项目文件时：
- 使用 Linux 文件系统根目录：`\\wsl$\<DistroName>\home\<UserName>\Project`
- 不是 Windows 文件系统的根目录：`C:\Users\<UserName>\Project` 或 `/mnt/c/Users/<UserName>/Project$`
#### 定时清理内存
可以通过定时任务定期清理内存，编辑crontab设置每小时释放一次内存：

```bash
crontab -e
0 */1 * * * echo 3 > /proc/sys/vm/drop_caches
```

**设置后台启动**

执行以下命令，允许用户执行所有命令而不需要密码：

```bash
sudo bash -c "echo '$USER ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/$USER"
```

在Windows开机启动文件夹中添加一个以.vbs结尾的文件，内容如下：

```bash
set ws=wscript.CreateObject("wscript.shell")
ws.run "wsl -d Ubuntu", 0
```

要快速进入开机启动文件夹，可以按Windows+R，然后输入 `shell:startup`。你可能还会用到 `taskschd.msc`。

**设置Ubuntu内的应用开机自启**

在WSL系统内新建并添加以下内容：

```bash
vim /etc/wsl.conf
###
[boot]
systemd=true
###
```

然后开启Ubuntu的开机启动服务：

```bash
systemctl status rc-local
```

并添加以下内容：

```bash

cat <<EOF >/etc/rc.local
# !/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
exit 0
EOF
```

执行以下命令使脚本可执行并启用：

```bash

chmod +x /etc/rc.local
systemctl enable --now rc-local

```

无视警告即可：

```bash

systemctl status rc-local.service

```

修改 `/etc/rc.local` 里的内容即可让你的Ubuntu应用开机启动。

## 其他的一些必要配置：

### 设置root密码，开机必备

```bash

sudo passwd root

```

### 更新系统

```bash

su -
apt-get update && apt-get upgrade

```

### WSL2 Ubuntu 安装openssh-server

```bash

sudo apt update
sudo apt install openssh-server

```

### WSL2 启用systemd

在/etc目录下新建wsl.conf配置文件，并编辑该配置文件：

### Ubuntu

```bash

sudo vi /etc/wsl.conf

```

输入内容：

```

[boot]
systemd=true

```

### Windows

在 Windows PowerShell(管理员)中运行：

```bash

wsl --shutdown

```

再重新打开 Ubuntu，使 WSL 彻底重新启动以便启用 systemd。然后在 WSL 中运行：

### 让你的ssh开机自启

```bash

systemctl enable ssh
systemctl start ssh

```

请注意你的ssh的登录安全，按照你的安全习惯配置即可。

**清理磁盘空间**

在 Linux 下回收文件系统上所有未使用的块：

```bash
sudo fstrim /
```

对于 Win10 专业版，使用如下命令压缩 WSL 虚拟机占用空间：

```powershell
wsl --shutdown
optimize-vhd -Path "{安装位置\\ext4.vhdx}" -Mode full
```

对于家庭版：

```powershell
wsl --shutdown
diskpart
# 打开新的 Diskpart 窗口select vdisk file="{安装位置\\ext4.vhdx}"
attach vdisk readonly
compact vdisk
detach vdisk
exit
```

### 进一步学习

学完以上基础内容后，你可能会感兴趣以下内容：

- 如何在WSL2内运行大模型，如部署本地的ollama或吾皇的GPT；
- 如何让你的本地模型在外网随时可访问，如部署Tailscale或ZeroTrust；
- 还有哪些有趣的场景可以探索？

写了这么多，给个赞，升个三级不过分吧！

**Update**：关于评论里提到的网络配置问题，**NAT模式**（WSL2默认）下已满足需要，有更多需求的请参看底部参考资料3的内容

[https://linux.do/t/topic/132043](https://linux.do/t/topic/132043)

[https://dowww.spencerwoo.com/](https://dowww.spencerwoo.com/)

[https://www.cnblogs.com/wswind/p/17201979.html](https://www.cnblogs.com/wswind/p/17201979.html)

[https://learn.microsoft.com/zh-cn/windows/wsl/install](https://learn.microsoft.com/zh-cn/windows/wsl/install)

[https://www.sxrhhh.top/blog/2023/12/14/connect-to-wsl/#_4](https://www.sxrhhh.top/blog/2023/12/14/connect-to-wsl/#_4)

[https://learn.microsoft.com/zh-cn/windows/wsl/wsl-config#wslconf](https://learn.microsoft.com/zh-cn/windows/wsl/wsl-config#wslconf)