---
layout: post
title: 在 Ubuntu 下安装 Intel ixgbe 网卡驱动
description: Linux 下的 Intel ixgbe 网卡驱动的安装方法
---

大部分的 Linux 发行版会内置 Intel 以及其他厂商的各种网卡驱动。然而很多公司不愿意升级到新系统，从而导致很多新的硬件设备无法正常工作，这个时候就需要我们手动来编译和安装网卡驱动。

### Intel ixgbe 网卡驱动硬件支持列表

    * Intel(R) Ethernet Controller 82598
    * Intel(R) Ethernet Controller 82599
    * Intel(R) Ethernet Controller X520
    * Intel(R) Ethernet Controller X540
    * Intel(R) Ethernet Controller x550
    * Intel(R) Ethernet Controller X552
    * Intel(R) Ethernet Controller X553

Intel 的 ixgbe 驱动主要用于 Intel 公司的千兆以及万兆以太网卡，并且默认情况下只支持 Intel 原厂的 sfp 或 sfp+ 模块。如果想要支持非原厂的模块后面会有讲解！

### 如何查看当前 ixgbe 驱动所支持的网卡型号？

首先使用 lspci 工具查看当前系统中的网卡生产厂商和具体型号

    $ lspci -nn | grep Ethernet

然后 lspci 工具会列出当前系统上的所有以太网卡设备以及厂商和型号

    00:03.0 Ethernet controller [0200]: Intel Corporation 82540EM Gigabit Ethernet Controller [8086:100e] (rev 02)

从上面的结果中可以看到有一个 Intel 82540EM 型号的网卡设备，而后面的 `8086:100e` 就是这个网卡的数字编号。通常大多数 Linux 系统都预装了 ixgbe 驱动，然后使用 modinfo 命令查看当前 ixgbe 驱动所支持的网卡型号都有哪些

    $ modinfo ixgbe

在使用 modinfo 工具查询的结果中，我们可以查找是否有数字编号为 `8086:100e` 的网卡型号列表

    filename:       /lib/modules/3.13.0-32-generic/kernel/drivers/net/ethernet/intel/ixgbe/ixgbe.ko
    version:        3.15.1-k
    license:        GPL
    description:    Intel(R) 10 Gigabit PCI Express Network Driver
    author:         Intel Corporation, <linux.nics@intel.com>
    srcversion:     75370FD447E0C306FEDB41F
    alias:          pci:v00008086d00001012sv*sd*bc*sc*i*
    alias:          pci:v00008086d00001011sv*sd*bc*sc*i*
    alias:          pci:v00008086d00001010sv*sd*bc*sc*i*
    alias:          pci:v00008086d0000100Fsv*sd*bc*sc*i*
    alias:          pci:v00008086d0000100Esv*sd*bc*sc*i*
    alias:          pci:v00008086d0000100Dsv*sd*bc*sc*i*
    alias:          pci:v00008086d0000100Csv*sd*bc*sc*i*
    . . .

从上面的 ixgbe 驱动支持列表中，我们找到了下面这一行，也就表示 ixgbe 驱动支持此网卡型号

    alias:          pci:v00008086d0000100Esv*sd*bc*sc*i*
                             ^^^^     ^^^^

### 如何手动安装 Intel ixgbe 网卡驱动

如果当前系统中的 ixgbe 驱动不支持你的网卡，我们就需要手动来安装新版本的 ixgbe 驱动
​

1) 安装系统 Linux 内核头文件

    $ apt-get install linux-headers-$(uname -r)

2) 安装基础编译环境所需的软件包

    $ apt-get install gcc make automake autoconf libtool

3) 从 Intel 官网下载 ixgbe 驱动安装包

    $ wget https://downloadmirror.intel.com/14687/eng/ixgbe-5.6.1.tar.gz

4) 然后开始编译 ixgbe 驱动模块
```
$ tar -zxvf ixgbe-5.6.1.tar.gz
$ cd ixgbe-5.6.1/src
$ make
```

5) 删除旧的 ixgbe 驱动，并安装新的 ixgbe 驱动模块
```
$ modprobe -r ixgbe
$ find /lib/modules/3.13.0-32-generic -name ixgbe.ko -exec rm -f {} \;
$ find /lib/modules/3.13.0-32-generic -name ixgbe.ko.gz -exec rm -f {} \;
$ install -D -m 644 ixgbe.ko /lib/modules/3.13.0-32-generic/kernel/drivers/net/ethernet/intel/ixgbe/ixgbe.ko
```

6) 最后一步，重新生成内核模块列表，并更新 initramfs
```
$ depmod -a
$ update-initramfs -u -k all
```

至此 ixgbe 的驱动就安装 OK 了，使用下面的命令加载 ixgbe 模块就可以使用新网卡驱动了

    $ modprobe ixgbe

### 解决 ixgbe 不支持第三方  sfp/sfp+ 模块问题

默认情况下 ixgbe 驱动只支持 Intel 原厂的 sfp/sfp+ 光口模块，也就是说可能会出现以下这样的错误信息

    [ 1280.139502 ] ixgbe 0000:02:00.0: failed to load because an unsupported SFP+ or QSFP module type was detected

这时我们可以在加载 ixgbe 驱动模块的时候，给 ixgbe 模块设置一个参数，来让它支持第三方品牌的光口模块

    $ modprobe ixgbe allow_unsupported_sfp=1

当然也可将 ixgbe 模块参数添加到 /etc/modprobe.d/ixgbe.conf 配置文件中，以确保开机重启后模块能正常工作

    echo "options ixgbe allow_unsupported_sfp=1" > /etc/modprobe.d/ixgbe.conf
