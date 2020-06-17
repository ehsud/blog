
---
layout: post
title: Asterisk 16 在 CentOS 7 安装手记
description: 详解 Asterisk 16 在 CentOS 7 安装手记
---

Asterisk 在 CentOS 7 版本下的安装方法

### 准备环境

* CentOS 7 x64
* Asterisk 16 certified

1. 首先安装基础编译依赖环境包

```
$ yum groups install "Development Tools"
```

2. 下载 asterisk 源码包

```
$ curl http://downloads.asterisk.org/pub/telephony/certified-asterisk/asterisk-certified-16.8-current.tar.gz -o asterisk-certified-16.8-current.tar.gz
```

4. 解压 asterisk 源码包

```
$ tar -zxvf asterisk-certified-16.8-current.tar.gz
$ cd asterisk-certified-16.8-cert2
```

5 . 安装 Asterisk 需要的一些依赖包，并开始编译安装

```
$ ./contrib/scripts/install_prereq install
$ ./configure --with-jansson-bundled
$ make && make install
```

> 默认情况下 Asterisk 安装需要 jansson 与 pjproject 依赖包，如果在 configure 无法下载的情况下，则需要手动下载以下两个包

```
$ curl https://raw.githubusercontent.com/asterisk/third-party/master/jansson/2.12/jansson-2.12.tar.bz2 -o /tmp/jansson-2.12.tar.bz2
$ curl https://raw.githubusercontent.com/asterisk/third-party/master/pjproject/2.9/pjproject-2.9.tar.bz2 -o /tmp/pjproject-2.9.tar.bz2

```

6. 安装 Asterisk 基础配置文件

```
$ make 
```
