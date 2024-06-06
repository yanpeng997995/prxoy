#!/bin/bash
function socks5() {
# 判断是否是root用户
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi
# 判断是否为国内服务器
ip_address=$(curl -s ifconfig.me)
# 查询 IP 地址的归属地
location=$(curl -s https://ipapi.co/${ip_address}/country/)
# 判断归属地是否为中国
if [ "$location" == "CN" ]; then
    read -p "检测到您在中国，是否需要使用代理？(y/n): " USE_PROXY
    if [ "$USE_PROXY" == "y" ]; then
        export HTTP_proxy=http://111:111@43.131.15.135:13150
    fi
fi
# 交互式提示设置端口
read -p "请输入端口: " PORT
read -p "请输入用户名: " USER
read -p "请输入密码: " PASSWD

# 设置链接变量
REQUEST_SERVER=${REQUEST_SERVER:-"https://raw.github.com/Lozy/danted/master"}
# 查询操作系统
if [ -s "/etc/os-release" ]; then
    os_name=$(sed -n 's/PRETTY_NAME="\(.*\)"/\1/p' /etc/os-release)
elif [ -s "/etc/issue" ]; then
    os_name=$(grep -Ei 'CentOS' /etc/issue)
else
    printf "[Error] (/etc/os-release) OR (/etc/issue) not exist!\n"
    printf "[Error] Current OS: is not available to support.\n"
    exit 1
fi
# 输出操作系统信息
if [ -n "$os_name" ]; then
    printf "当前操作系统: %s\n" "${os_name}"
else
    printf "[Error] 获取操作系统信息失败！\n"
    exit 1
fi
# 输出参数信息
if [ -n "$PORT" ]; then
    printf "端口号: %s\n" "$PORT"
fi
if [ -n "$USER" ]; then
    printf "用户名: %s\n" "$USER"
fi
if [ -n "$PASSWD" ]; then
    printf "密码: %s\n" "$PASSWD"
fi
# 执行安装脚本
if [ -n "$os_name" ]; then
    if [ -n "$(echo ${os_name} | grep -Ei 'Debian|Ubuntu' )" ]; then
        wget -qO- --no-check-certificate ${REQUEST_SERVER}/install_debian.sh | \
            bash -s -- --port="$PORT" --user="$USER" --passwd="$PASSWD" | tee /tmp/danted_install.log
    elif [ -n "$(echo ${os_name} | grep -Ei 'CentOS')" ]; then
        wget -qO- --no-check-certificate ${REQUEST_SERVER}/install_centos.sh | \
            bash -s -- --port="$PORT" --user="$USER" --passwd="$PASSWD" | tee /tmp/danted_install.log
    else
        printf "[Error] 不支持的操作系统: %s\n" "${os_name}"
        exit 1
    fi
fi

exit 0
}

#搭建SSR
function ssr() {
# 安装 wget
yum -y install wget

# 下载并运行 ssr.sh 脚本
# 判断是否为国内服务器
ip_address=$(curl -s ifconfig.me)
# 查询 IP 地址的归属地
location=$(curl -s https://ipapi.co/${ip_address}/country/)
# 判断归属地是否为中国
if [ "$location" == "CN" ]; then
    read -p "检测到您在中国，是否需要使用代理？(y/n): " USE_PROXY
    if [ "$USE_PROXY" == "y" ]; then
        export HTTP_proxy=http://111:111@43.131.15.135:13150
    fi
fi
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ssr.sh
chmod +x ssr.sh
bash ssr.sh
}
# 主菜单
function main_menu() {
    while true; do
        clear
        echo "脚本由游艇舰队----迫击炮进行编写"
        echo "=========================基于github仓库修改======================================="
        echo "节点社区:微信             微信联系:17784902889"
        echo "欢迎各位交流，包括低价腾讯云，阿里云，华为云服务器：17784902889"
        echo "退出脚本，请按键盘ctrl c退出即可"
        echo "请选择要执行的操作:"
        echo "1. 安装socks5"
        echo "2. 安装ssr协议"
        read -p "请输入选项（1-5）: " OPTION

        case $OPTION in
        1) socks5 ;;
        2) ssr ;;
        *) echo "无效选项。" ;;
        esac
        echo "按任意键返回主菜单..."
        read -n 1
    done
}

# 显示主菜单
main_menu
