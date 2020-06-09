---
layout: post
title: Archlinux 二层网卡桥接
description: 在 Archlinux 中使用网卡桥接
category: [linux]
tags: [linux, archlinux,]
---

在 ArchLinux 中如果有多块网卡，可以实现将多块网卡进行桥接，当作一台二层交换机来使用。Archlinux 使用 iproute2 软件包管理网卡桥接

### 准备环境

假如有一台 Archlinux 的机器，有 3 块网卡如下

* enp10 第一块网卡
* enp20 第二块网卡
* enp30 第三块网卡

默认情况下 Archlinux 安装好之后就自带 iproute2 软件包，因为 iproute2 已经包含在了 Archlinux 的基础系统组件里面

### 开始配置

1. 首先需要创建一个名称为 br0 的虚拟网桥

```
$ ip link add name br0 type bridge
```

> 提示：网桥名称可以自由定义

2. 将 br0 网桥设置为启用状态

```
$ ip link set br0 up
```

当然也可以给 br0 网桥配置一个 IP 地址

```
$ ip addr add 192.168.10.1/24 dev br0
```

3. 将现有的三块网卡状态设置为启用

```
$ ip link set enp10 up
$ ip link set enp20 up
$ ip link set enp30 up
```

4. 将现有三块网卡加入到 br0 网桥中

```
$ ip link set enp10 master br0
$ ip link set enp20 master br0
$ ip link set enp30 master br0
```

以上配置就将 `enp10`、`enp20` 、`enp30` 三块网卡加入到 `br0` 网桥之中实现二层交换机的功能。当然也可以给这三块网卡分别配置一个 IP 地址

```
$ ip addr add 192.168.10.10/24 dev enp10
$ ip addr add 192.168.10.20/24 dev enp20
$ ip addr add 192.168.10.30/24 dev enp30
```

### 网桥的管理

1. 如何查看已经加入到网桥的网卡配置信息

```
$ bridge link
```

`bridge` 命令属于 iproute2 软件包中的一个工具，我们可以用它来查看网桥的配置信息

2. 将一个网卡从网桥中删除，比如 enp10 网卡

```
$ ip link set enp10 nomaster
```

这个时候 enp10 网卡仍然是被启用状态，可能需要使用下面的命令彻底关闭它

```
$ ip link set enp10 down
```

3. 如何将 br0 网桥删除，方法如下

```
$ ip link delete br0 type bridge
```

