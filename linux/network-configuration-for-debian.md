---
layout: post
title: Debian 网络配置方法
description: 详解 Debian 下的网络配置方法
---

### Debian 10 网络配置方法

在 Debian 下最简单的网络配置方式是使用 `networking` 服务，默认配置文件位于 `/etc/network/interfaces`

#### 配置 DHCP 动态 IP 地址

编辑 `/etc/network/interfaces` 网卡配置文件

```
auto enp0s3
iface enp0s3 inet dhcp
```

#### 配置 STATIC 静态 IP 地址

编辑 `/etc/network/interfaces` 网卡配置文件

```
auto enp0s3
iface enp0s3 inet static
address 192.168.1.100
netmask 255.255.255.0
gateway 192.168.1.1
dns-nameservers 8.8.8.8,8.8.4.4
```

#### 重启网络服务，使配置生效

修改网卡配置文件之后，需要重启 `networking` 服务使配置生效

```
$ systemctl restart networking
```
