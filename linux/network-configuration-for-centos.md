---
layout: post
title: CentOS 网络配置方法
description: 详解 CentOS 各版本下的网络配置方法
---

### CentOS 7 网络配置方法

在 CentOS 7 版本下最简单的网络配置方式是使用 `network` 服务，默认配置文件位于 `/etc/sysconfig/network-scripts` 下

#### 配置 DHCP 动态 IP 地址

编辑 `/etc/sysconfig/network-scripts/ifcfg-enp0s3` 网卡配置文件

```
TYPE=Ethernet
NAME=enp0s3
UUID=AADCB6BD-17F7-4644-9386-9288DAE647D5
DEVICE=enp0s3
ONBOOT=yes
BOOTPROTO=dhcp
```

#### 配置 STATIC 静态 IP 地址

编辑 `/etc/sysconfig/network-scripts/ifcfg-enp0s3` 网卡配置文件

```
TYPE=Ethernet
NAME=enp0s3
UUID=AADCB6BD-17F7-4644-9386-9288DAE647D5
DEVICE=enp0s3
ONBOOT=yes
BOOTPROTO=dhcp
IPADDR=192.168.1.100
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
```

#### 重启 network 服务，使配置生效

修改网卡配置文件之后，需要重启 `network` 服务使配置生效

```
$ systemctl restart network
```
