---
layout: post
title: 如何搭建 ISCSI Linux 存储服务器
description: 如何在 Linux 下搭建一个 ISCSI 存储服务器
---

在 Linux 2.6.38 版本之前，Linux 下使用的是 SCSI Target Framework (STGT/TGT) 这种框架来实现的 ISCSI 功能，技术相对陈旧。而现在 Linux 最新的标准使用的是 LIO target，它基于内核模块，性能相比之前的 STGT/TGT 要高效。


### 什么是 ISCSI ？

首先 scsi 是一种硬盘存储设备接口，类似 stat 、sas 等。而 iscsi 是一种源于早期的 scsi 存储接口的新协议，早期的 scsi 接口只是用于本地接口设备，不能跨网络主机共享。后来 IBM 等大公司开发了一种能跑在以太网上的 scsi 协议，也就是今天我们要讲的 iscsi 协议，iscsi 的原理就是将原始的 scsi 协议封装在 TCP/IP 以太网协议里面，基于 TCP/IP 来实现跨网络主机共享和访问。

通常在 iscsi 技术中，分为 iscsi initiator (会话发起器) 和 iscsi target (目标存储位置) 这两个概念，因为 iscsi 是一种 C/S 结构工作模式，也就是 iscsi initiator 是客户端，iscsi target 是服务器端。通常我们在 iscsi 服务器端创建一些 LUN 的逻辑存储单元，然后其他客户端服务器通过 iscsi initiator 来连接此 iscsi target 服务端挂载和使用这些 LUN 存储设备

### 安装 targetcli 工具

- 服务器环境为 CentOS 7 ，用到的工具为 targetcli

早期的 CentOS 6 以前的版本使用的是 tgt 工具，现在新的 CentOS 7 版本建议使用 targetcli 工具

    $ yum install -y targetcli

### targetcli 的基本使用方法

启动 targetcli 工具后，会显示下面的内容

    $ targetcli

    targetcli shell version 2.1.fb46
    Copyright 2011-2013 by Datera, Inc and others.
    For help on commands, type 'help'.

    />

因为 targetcli 工具可以使用命令行模式、也可以使用交互模式，而默认是交互模式，所以启动后会进入一个交互式操作界面，targetcli 以目录结构的方式显示各种配置信息，我们可以使用 ls 命令来显示当前的 iscsi 配置信息，也可以使用 cd 命令进入某个目录下

    /> ls

    o- / ..................................................... [...]
      o- backstores .......................................... [...]
      | o- block ............................................. [Storage Objects: 0]
      | o- fileio ............................................ [Storage Objects: 0]
      | o- pscsi ............................................. [Storage Objects: 0]
      | o- ramdisk ........................................... [Storage Objects: 0]
    o- iscsi ................................................. [Targets: 0]
    o- loopback .............................................. [Targets: 0]

- `backstores`： 表示 iscsi 支持的一些设备类型
- `iscsi`： 就是当前可用的 iscsi LUN 逻辑存储单元，这里没有创建任何 LUN 存储单元，所以显示为空

另外 `backstores` 可以是一个本地硬盘，或者分区磁盘，也可是一些外接的 scsi 硬盘，还支持将文件和内存作为一个块存储设备来使用

### 创建一个 LUN 存储单元

**1)** 首先将一个 /dev/sdb 的硬盘创建为 iscsi 逻辑存储单元

    /> cd /backstores/block
    /> create lun0 /dev/sdb

    Created block lun0 with size 10485760

2) 创建一个 iscsi 目标 iqn

    /> cd /iscsi
    /> create

    Created target iqn.2003-01.org.linux-iscsi.server.x8664:sn.a0bed4ed5f7a.
    Created TPG 1.
    Global pref auto_add_default_portal=true
    Created default portal listening on all IPs (0.0.0.0), port 3260.

其中 `iqn.2003-01.org.linux-iscsi.island.x8664:sn.a0bed4ed5f7a` 表示 targetcli 自动创建的 iqn 名称，当然也可以自己手动指定一个 iqn 名称，当手动指定 qin 名称时一定要按照标准的 iqn 格式，否则有些系统无法使用或者报错，后面所有的使用和配置都会要使用这个 iqn 名称

3) 将 lun0 绑定到新创建的 iqn 里面

    /> cd /iscsi/iqn.2003-01.org.linux-iscsi.server.x8664:sn.a0bed4ed5f7a/tpg1/luns
    /> create /backstores/block/lun0

4) 添加客户端到 acls 访问控制列表中

首先获取客户端的 iqn 名称，然后执行下面的命令将其添加到 acl 访问控制列表

    /> cd /iscsi/iqn.2003-01.org.linux-iscsi.server.x8664:sn.a0bed4ed5f7a/tpg1/acls
    /> create iqn.1990-07.com.redhat:f1fe809fef89

默认 iscsi 服务器可以被任何客户端访问，这样是非常不安全的，所以需要配置 acl 访问列表

5) 最后配置完成后，将配置保存到配置文件

    /> saveconfig

为了在重启后 iscsi 服务能正常运行，需要将 target.service 服务设置为开机启动

    $ systemctl enable target.service


### 客户端 iscsi 的连接和使用

首先使用 iscsiadm 工具获取服务器端的存储设备列表

    $ iscsiadm -m discovery -t sendtargets -p 192.168.1.100

    192.168.1.100,1 iqn.2003-01.org.linux-iscsi.server.x8664:sn.a0bed4ed5f7a

然后登录到 iscsi 服务器端来连接和挂载 iscsi 服务器上的存储设备

    $ iscsiadm -m node -l -p 192.168.1.100 -T iqn.2003-01.org.linux-iscsi.server.x8664:sn.a0bed4ed5f7a

使用 iscsiadm 登录连接到 iscsi 服务器端后，使用 lsblk 就能看到新的磁盘设备

    $lsblk

    NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    sda    253:0    0  100G  0 disk
    ├─sda1 253:2    0   50G  0 part /
    └─sda2 253:1    0    2G  0 part [SWAP]

    sdb    8:50     0   50G  0 disk

