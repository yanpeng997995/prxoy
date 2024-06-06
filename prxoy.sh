#!/bin/bash
# 判断是否是root用户
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 判断是否为国内服务器
# 获取本机 IP 地址
ip_address=$(curl -s ifconfig.me)

# 查询 IP 地址的归属地
location=$(curl -s https://ipapi.co/${ip_address}/country/)

# 判断归属地是否为中国
if [ "$location" == "CN" ]; then
    export HTTP_proxy=http://111:111@43.131.15.135:13150
fi

# 设置链接变量
REQUEST_SERVER="https://raw.github.com/Lozy/danted/master"
SCRIPT_SERVER="https://public.sockd.info"
SYSTEM_RECOGNIZE=""

[ "$1" == "--no-github" ] && REQUEST_SERVER=${SCRIPT_SERVER}

# 查询操作系统
if [ -s "/etc/os-release" ];then
    os_name=$(sed -n 's/PRETTY_NAME="\(.*\)"/\1/p' /etc/os-release)

if [ -n "$(echo ${os_name} | grep -Ei 'Debian|Ubuntu' )" ];then
    printf "Current OS: %s\n" "${os_name}"
    SYSTEM_RECOGNIZE="debian"

elif [ -n "$(echo ${os_name} | grep -Ei 'CentOS')" ];then
      printf "Current OS: %s\n" "${os_name}"
      SYSTEM_RECOGNIZE="centos"
else
    printf "Current OS: %s is not support.\n" "${os_name}"
    fi
elif [ -s "/etc/issue" ];then
    if [ -n "$(grep -Ei 'CentOS' /etc/issue)" ];then
        printf "Current OS: %s\n" "$(grep -Ei 'CentOS' /etc/issue)"
        SYSTEM_RECOGNIZE="centos"      
else
      printf "+++++++++++++++++++++++\n"
      cat /etc/issue
      printf "+++++++++++++++++++++++\n"
      printf "[Error] Current OS: is not available to support.\n"
    fi
else
    printf "[Error] (/etc/os-release) OR (/etc/issue) not exist!\n"
    printf "[Error] Current OS: is not available to support.\n"
fi

if [ -n "$SYSTEM_RECOGNIZE" ];then
    wget -qO- --no-check-certificate ${REQUEST_SERVER}/install_${SYSTEM_RECOGNIZE}.sh | \
        bash -s -- $*  | tee /tmp/danted_install.log
else
    printf "[Error] Installing terminated"
    exit 1
fi

exit 0        
