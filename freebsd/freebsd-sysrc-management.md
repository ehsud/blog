---
layout: post
title: freebsd 的 sysrc 系统配置工具
description: FreeBSD 的 sysrc rc.conf 文件配置工具
---


sysrc 是 FreeBSD 系统下的 rc 配置文件修改工具，它使用命令行 `key=value` 键值对方式来修改 /etc/rc.conf 中的内容，避免了我们手动修改带来的一些不便和问题。最常用的应用场景是使用 sysrc 来开启和关闭一些系统开机服务以及服务参数配置

### sysrc 的基本使用方法

```
Usage: sysrc [OPTIONS] {name[[+|-]=value] ... | -a | -A | -l | -L [name ...]}
```

sysrc 默认会使用到 `/etc/rc.conf` 和 `/etc/defaults/rc.conf` 两个配置文件，当然可能还会用到其他目录下的一些用户自定义的配置文件

**1. 使用 sysrc 查看一些默认的变量配置**

```
$ sysrc -a
```

`-a` 选项会显示 `/etc/rc.conf` 中的配置内容，使用 `-A` 会同时显示 `/etc/defaults/rc.conf` 中的内容

**2. 使用 sysrc 查看某个选项的描述说明**

```
$ sysrc -d sshd_enable
```

**3. 使用 sysrc 开启 sshd 远程登录服务**

```
$ sysrc sshd_enable="YES"
```

**4. 使用 sysrc 禁用 sshd 远程登录服务**

```
$ sysrc sshd_enable="NO"
```

**5. 向参数选项追加一个值，而不是替换原来的值，使用 `name+=value`**

```
$ sysrc cloned_interfaces+="em1"
```

默认 sysrc 会自动将新值使用空格分隔符追加到原来的值后面，其最终结果如下

```
cloned_interfaces="em0 em1"
```

当然如果值的第一个字符是 Alpha 字母，也就是 `A-Z`、`a-z`、`0-9`、`()` `.` `/` 等字符，sysrc 会默认使用空格作为分隔符

**6. 删除某个选项中的一个值，跟上面的类似，只不过是使用 `name-=value`**

```
$ sysrc cloned_interfaces-="em1"
```

这条命令的最终的结果如下。如果原来选项的值只有一个，最终该选项的值会被设置为空字符串 `""`

```
cloned_interfaces="em0"
```

**7. 使用 sysrc 删除一个 rc 配置文件中的变量选项**

```
$ sysrc -x dumpdev
```
