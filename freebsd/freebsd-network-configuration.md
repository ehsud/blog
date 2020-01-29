---
layout: post
title: freebsd 网络配置方法与使用
description: 详解 freebsd 网络配置与使用方法
---

freebsd 的网络是使用 rc.conf 配置文件来配置的，包括 IP 地址，默认路由都是如此，当然也可使用 ifconfig 工具手动配置临时 IP 地址

### freebsd 静态 IP 地址的配置

为了方便，我们使用 `sysrc` 工具修改 rc.conf 文件来配置 IP 地址

**配置一个默认的主机名，是一个好的习惯**

```
$ sysrc hostname="localhost"
```

**设置 freebsd 的默认网关路由**

```
$ sysrc defaultrouter="192.168.1.1"
```

**设置 freebsd 网卡的静态 IP 地址和子网掩码**

```
$ sysrc ifconfig_em0="inet 192.168.124.252 netmask 255.255.255.0"
```
变量 `ifconfig_em0` 中的 `em0` 表示网卡名称，`inet` 表示 IP 地址，`netmask` 为子网掩码

### freebsd 动态 DHCP 获取 IP 地址的配置

freebsd 的 DHCP 动态 IP 地址配置就这么简单
```
$ sysrc ifconfig_em0="DHCP"
```

**配置静态 IP 或 DHCP 之后，需要重启网络服务，以使配置生效**

第一种方法使用 `netstart` 也是最简单的方法

```
$ /etc/netstart
```

第二种方法使用 `service` 工具重启 `netif` 和 `routing` 服务

```
$ service netif restart
$ service routing restart
```

### freebsd 的 DNS 服务器配置

freebsd 默认 dns 配置与 Linux 的方法一样，都是使用 /etc/resolv.conf 配置文件来配置

```
nameserver 8.8.8.8
nameserver 8.8.4.4
```
