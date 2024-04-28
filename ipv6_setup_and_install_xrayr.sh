#!/bin/bash

# 默认设置
DEFAULT_DOMAIN="example.com"
DEFAULT_EMAIL="your_email@example.com"

# 询问用户输入域名和邮箱地址
read -p "请输入要申请 SSL 证书的域名（默认值：$DEFAULT_DOMAIN）: " DOMAIN
read -p "请输入 SSL 证书的邮箱地址（默认值：$DEFAULT_EMAIL）: " EMAIL

# 如果用户未输入任何内容，则使用默认设置
DOMAIN=${DOMAIN:-$DEFAULT_DOMAIN}
EMAIL=${EMAIL:-$DEFAULT_EMAIL}

# 设置防火墙规则
echo "设置防火墙规则..."
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F
iptables-save

# 更新系统
echo "更新系统..."
apt update -y

# 安装依赖
echo "安装依赖..."
apt install -y wget curl socat cron

# 安装 Warp
echo "安装 Warp..."
wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh

# 安装XrayR
echo "安装XrayR..."
bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)

# 安装签发证书工具
echo "安装签发证书工具..."
curl https://get.acme.sh | sh

# 申请 SSL 证书，并下载到服务器目录
echo "申请 SSL 证书，并下载到服务器目录..."
~/.acme.sh/acme.sh --register-account -m $EMAIL
~/.acme.sh/acme.sh --issue -d $DOMAIN --standalone --listen-v6
~/.acme.sh/acme.sh --installcert -d $DOMAIN --key-file /etc/XrayR/private.key --fullchain-file /etc/XrayR/cert.crt

echo "安装成功!"
