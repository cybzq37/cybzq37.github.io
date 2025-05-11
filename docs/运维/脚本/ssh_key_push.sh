#!/bin/bash

# 配置变量
SSH_KEY="$HOME/.ssh/id_rsa"
TMP_SSH_DIR=".remote_ssh_tmp"  # 临时存放公钥的目录

# 目标主机列表（格式：user@host:port）
HOSTS=(
  "root@171.17.171.21:22"        # 远程机器 1
  "root@171.17.171.22:22"      # 远程机器 2
  "root@171.17.171.23:22"        # 本机（假设本机的 IP 为 171.17.171.23）
)

# 目标主机对应的密码列表
PASSWORDS=(
  "123456"
  "123456"
  "123456"
)

# 1. 检查是否已经生成 SSH 密钥对
if [ ! -f "$SSH_KEY" ]; then
  echo "未检测到 SSH 密钥，正在生成..."
  ssh-keygen -t rsa -N "" -f "$SSH_KEY"
else
  echo "已检测到 SSH 密钥：$SSH_KEY"
fi

# 2. 读取主机列表并将公钥推送到每个远程主机
for index in "${!HOSTS[@]}"; do
  USER_HOST="${HOSTS[$index]}"  # 用户名和主机
  PASSWORD="${PASSWORDS[$index]}"  # 对应密码
  USER=$(echo "$USER_HOST" | cut -d@ -f1)  # 提取用户名
  HOST=$(echo "$USER_HOST" | cut -d@ -f2 | cut -d: -f1)  # 提取主机地址
  PORT=$(echo "$USER_HOST" | cut -d: -f2)  # 提取端口号

  # 3. 自动跳过主机密钥验证
  echo "正在添加 $HOST 到 known_hosts..."
  ssh-keyscan -H "$HOST" >> ~/.ssh/known_hosts

  # 4. 创建临时目录并将公钥传输到远程主机
  echo "正在将公钥推送到 $USER@$HOST..."
  sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -p "$PORT" "$USER@$HOST" "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo $(cat ~/.ssh/id_rsa.pub) >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

  # 5. 同步私钥到远程主机
  echo "正在同步私钥到 $USER@$HOST..."
  sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no -P "$PORT" "$SSH_KEY" "$USER@$HOST:~/.ssh/id_rsa"
  sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no -P "$PORT" "$SSH_KEY.pub" "$USER@$HOST:~/.ssh/id_rsa.pub"

  # 6. 设置私钥权限并清理临时文件
  sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -p "$PORT" "$USER@$HOST" "chmod 600 ~/.ssh/id_rsa && chmod 644 ~/.ssh/id_rsa.pub"

  echo "✅ 公钥已成功推送到 $USER@$HOST"
done

# 7. 测试免密登录
echo "正在测试免密登录..."
for index in "${!HOSTS[@]}"; do
  USER_HOST="${HOSTS[$index]}"  # 用户名和主机
  PASSWORD="${PASSWORDS[$index]}"  # 对应密码
  USER=$(echo "$USER_HOST" | cut -d@ -f1)  # 提取用户名
  HOST=$(echo "$USER_HOST" | cut -d@ -f2 | cut -d: -f1)  # 提取主机地址
  PORT=$(echo "$USER_HOST" | cut -d: -f2)  # 提取端口号

  # 免密登录测试
  sshpass -p "$PASSWORD" ssh -o BatchMode=yes -o ConnectTimeout=3 -o StrictHostKeyChecking=no -p "$PORT" "$USER@$HOST" "echo ✅ [$USER@$HOST] 免密登录成功" 2>/dev/null || echo "❌ [$USER@$HOST] 登录失败，请检查"
done

echo "所有操作完成。"

