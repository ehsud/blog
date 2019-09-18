---
layout: post
title: Ubuntu 网络配置方法
description: 详解 ubuntu 各版本下的网络配置方法
---

### Ubuntu 18.04 LTS 版本

Ubuntu 从 17.10 版本开始，引入了 Netplan 网络管理工具，在 Ubuntu 18.04 版本中默认使用 Netplan 来配置网络，并且配置文件使用 yaml 格式

#### 配置 DHCP 动态 IP 地址

编辑 `/etc/netplan/50-cloud-init.yaml` 网络配置文件

```
network:
  version: 2
  ethernets:
    enp3s0:
      dhcp4: true
```

#### 配置 STATIC 静态 IP 地址

编辑 `/etc/netplan/50-cloud-init.yaml` 网络配置文件

```
network:
  version: 2
  ethernets:
    enp0s3:
	  addresses:
	    - 192.168.1.100/24
      gateway4: 192.168.1.1
	  nameservers:
	    addresses: [8.8.8.8, 8.8.4.4]
```

- 网卡设备： enp0s3
- 网卡IP地址：192.168.1.100/24
- 默认网关： 192.168.1.1
- 默认 DNS： 8.8.8.8、8.8.4.4 (可选)

使用 `netplan` 命令使配置生效

```
$ netplan apply
```
