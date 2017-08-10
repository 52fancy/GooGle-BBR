#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
rm -f $0

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install BBR"
    exit
fi

clear
echo "+------------------------------------------------------------------------+"
echo "|                          GooGle TCP BBR                                |"
echo "+------------------------------------------------------------------------+"
echo "|        A tool to auto-compile & install BBR on CentOS                  |"
echo "+------------------------------------------------------------------------+"
echo "|                 Welcome to  http://github.com/52fancy                  |"
echo "+------------------------------------------------------------------------+"

if [ ! -f "/boot/grub/grub.conf" ];then
	echo "不支持当前系统，即将退出程序！"
	exit
fi

Get_RHEL_Version()
{
    if grep -Eqi "release 5." /etc/redhat-release; then
        RHEL_Version='5'
    elif grep -Eqi "release 6." /etc/redhat-release; then
        RHEL_Version='6'
    elif grep -Eqi "release 7." /etc/redhat-release; then
        RHEL_Version='7'
    fi
}

Get_RHEL_Version
if [ $RHEL_Version != "6" ]; then
    echo "Error: You must be CentOS 6 to run this script, please use CentOS 6 to install BBR"
	exit
fi

Install()
{
    if lsmod | grep -Eqi "bbr"; then
	    echo "您已经成功安装BBR"
		exit
	else
	    read -p "即将升级内核？[Y]：" is_update
		if [[ ${is_update} == "y" || ${is_update} == "Y" ]]; then
		    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
            rpm -Uvh http://www.elrepo.org/elrepo-release-6-8.el6.elrepo.noarch.rpm
			yum --enablerepo=elrepo-kernel -y install kernel-ml kernel-ml-devel
			
			sed -i 's/^default=.*/default=0/g' /boot/grub/grub.conf
			
			sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
			sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
			echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
			echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
			
			sysctl -p >/dev/null 2>&1
			
			read -p "重启后生效，是否重启？[Y]：" is_reboot
			if [[ ${is_reboot} == "y" || ${is_reboot} == "Y" ]]; then
			    reboot
			else
			    exit
			fi
		else
		    echo "程序即将退出安装"
            exit
		fi
    fi
}

Install
exit
