---
layout: post
title: Archlinux 安装教程 UEFI
description: 介绍如何在 UEFI 模式下安装 archlinux 系统
copyleft: true
---

##### ArchLinux UEFI 安装教程 

ArchLinux 是一个适合动手能力较强的 Linux 高级用户使用的发行版，所有的基础系统和组件都需要自行定制和安装，官方并没有提供一个开箱即用的方案，ArchLinux 的信仰就是简单和轻量级。笔者也是一个忠实的 ArchLinux 信仰者。

##### 开始 ArchLinux 的安装

**使用 parted 工具进行分区**

```
    $ parted /dev/sda
    $ mklabel gpt
    $ mkpart ESP fat32 1MiB 513MiB
    $ mkpart primary ext4 513MiB 100%
    $ set 1 boot on
    $ quit
```

**挂载分区**

    $ mount /dev/sda2 /mnt
    $ mkdir -p /mnt/boot/efi
    $ mount /dev/sda1 /mnt/boot/efi

**下载并安装 ArchLinux**

    $ pacstrap -i /mnt base base-devel

**将分区表文件系统信息写入到刚安装好的系统 fstab 文件**

    $ genfstab -U -p /mnt >> /mnt/etc/fstab

**chroot 切换到新系统**

    $ arch-chroot /mnt

**设置系统字符集和语言环境** /etc/locale.gen

    en_US.UTF-8 UTF-8
    zh_CN.GB18030 GB18030
    zh_CN.GBK GBK
    zh_CN.UTF-8 UTF-8
    zh_CN GB2312

**使字符集生效**

    $ locale-gen

**设置系统默认语言** /etc/locale.conf

    LANG=zh_CN.UTF-8

**设置时区**

    $ ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

或者修改 /etc/timezone 配置文件

    Asia/Shanghai

**设置主机名** /etc/hostname

    archlinux

**初始化内存盘**

    $ mkinitcpio -p linux

**配置开启 pacman 源** /etc/pacman.conf

    [multilib]
    Include = /etc/pacman.d/mirrorlist

**安装 grub 启动管理器**

    $ pacman -Sy grub os-prober efibootmgr
    $ grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub --recheck
    $ grub-mkconfig -o /boot/grub/grub.cfg

**安装 grub 主题 (可选)**

    $ pacman -Sy deepin-grub2-themes

编辑配置文件 /etc/default/grub

    GRUB_THEME="/boot/grub/themes/deepin/theme.txt"

重新生成配置文件

    $grub-mkconfig -o /boot/grub/grub.cfg

**安装声音驱动**

    $ pacman -Sy alsa-utils pulseaudio pulseaudio-alsa
    $ alsamixer

1. 方向键 选中 Master 和 PCM
2. [M] 取消静音

**查看显卡芯片厂商和型号**

    $ lspci | grep VGA

**安装对应显卡芯片的驱动**

1. 通用：      xf86-video-vesa
2. Intel 显卡：xf86-video-intel
3. nVidia 显卡：
  - GeForce 7 以上：xf86-video-nouveau；nvidia
  - GeForce 6/7：xf86-video-nouveau；nvidia-304xx

4. AMD/ATI 显卡：xf86-video-ati

比如安装 intel 显卡驱动

    $ pacman -Sy xf86-video-intel libva-intel-driver

**安装 Xorg Server**

    $ pacman -Sy xorg-server xorg-xinit

**添加触摸板支持 （可选）**

    $ pacman -Sy xf86-input-synaptics

**安装字体**

    $ pacman -Sy ttf-dejavu wqy-zenhei wqy-microhei

**安装 xfec 桌面环境、电池插件、音量插件**

    $ pacman -Sy xfce4 xfce4-battery-plugin xfce4-mixer

**安装 slim 以及主题**

    $ pacman -S slim slim-themes archlinux-themes-slim
    $ systemctl enable slim.service

**图形界面启动方式两种**

1. startx 命令行启动

配置 xfce 桌面启动环境 ~/.xinitrc

    exec startxfce4

启动 xfce 桌面

    $ startx

**安装 fcitx 输入法**

    $ pacman -Sy fcitx-im

**配置 fcitx 输入法 ~/.xinitrc**

    export GTK_IM_MODULE=fcitx
    export QT_IM_MODULE=fcitx
    export XMODIFIERS="@im=fcitx"

KDM、GDM、LightDM 等显示管理器的用户，向 ~/.xprofile添加以上命令。
使用 startx 或 slim 的用户，向 ~/.xinitrc 添加以上命令。

**安装输入法引擎**

    拼音输入法：      fcitx-cloudpinyin fcitx-googlepinyin fcitx-libpinyin fcitx-sunpinyin  
    五笔、郑码输入法：fcitx-table-extra

    $ pacman -Sy fcitx-googlepinyin
