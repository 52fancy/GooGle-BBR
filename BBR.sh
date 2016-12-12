#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

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

Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        OS_Bit='64'
    else
        OS_Bit='32'
    fi
}

Install()
{
    Get_OS_Bit
    if uname -r | grep -Eqi "4.9."; then
	    if lsmod | grep -Eqi "bbr"; then
		    echo "您已经成功安装BBR"
		    exit
		else
		    if [ ! `cat /etc/sysctl.conf | grep -i -E "net.core.default_qdisc=fq"` ]; then
		        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
		    fi
		    if [ ! `cat /etc/sysctl.conf | grep -i -E "net.ipv4.tcp_congestion_control=bbr"` ]; then
		        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
		    fi
		    sysctl -p
		fi
	else
	    if [ ! -f "/boot/grub/grub.conf" ];then
			echo "不支持当前系统，即将退出程序！"
			exit
		fi
		
	    echo -n "内核不一致，即将替换内核 [y or n]:  "
		read code
		if [ $code = "y" -o $code = "Y" ]; then
		    if [ $OS_Bit = "64" ]; then
		        rpm -ivh https://github.com/52fancy/GooGle-BBR/raw/master/kernel/kernel-ml-4.9.0-1.el6.elrepo.x86_64.rpm --force
			fi
			if [ $OS_Bit = "32" ]; then
		        rpm -ivh https://github.com/52fancy/GooGle-BBR/raw/master/kernel/kernel-ml-4.9.0-1.el6.elrepo.i686.rpm --force
			fi
			
			kernel_default=`grep '^title ' /boot/grub/grub.conf | awk -F'title ' '{print i++ " : " $2}' | grep "4.9." | grep -v debug | cut -d' ' -f1`
			sed -i "s/^default.*/default=${kernel_default}/" /boot/grub/grub.conf
			
			if [ ! `cat /etc/sysctl.conf | grep -i -E "net.core.default_qdisc=fq"` ]; then
		        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
		    fi
		    if [ ! `cat /etc/sysctl.conf | grep -i -E "net.ipv4.tcp_congestion_control=bbr"` ]; then
		        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
		    fi
		    sysctl -p >/dev/null 2>&1
		
			rm -f $0
			echo -n "重启后生效，是否重启？[y]："
			read is_reboot
			if [ $is_reboot = "y" -o $is_reboot = "Y" ]; then
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
