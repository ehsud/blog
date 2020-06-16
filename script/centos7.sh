#!/bin/sh

systemctl disable kdump.service
systemctl stop kdump.service
systemctl disable microcode.service
systemctl stop microcode.service
systemctl disable postfix.service
systemctl stop postfix.service
systemctl disable firewalld.service
systemctl stop firewalld.service
rm -f /etc/security/limits.d/*
sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config
echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.conf
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_syncookies = 1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_tw_reuse = 1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_tw_recycle = 1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_fin_timeout = 30' >> /etc/sysctl.conf
echo 'fs.file-max = 2097152' >> /etc/sysctl.conf
echo 'fs.mqueue.msg_default = 10240' >> /etc/sysctl.conf
echo 'fs.mqueue.msg_max = 10240' >> /etc/sysctl.conf
echo 'fs.mqueue.msgsize_default = 8192' >> /etc/sysctl.conf
echo 'fs.mqueue.msgsize_max = 8192' >> /etc/sysctl.conf
echo 'fs.mqueue.queues_max = 256' >> /etc/sysctl.conf
echo '* soft nofile 102400' >> /etc/security/limits.conf
echo '* hard nofile 102400' >> /etc/security/limits.conf
echo '* soft nproc unlimited' >> /etc/security/limits.conf
echo '* hard nproc unlimited' >> /etc/security/limits.conf
