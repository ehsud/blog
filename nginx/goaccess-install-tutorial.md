---
layout: post
title: 日志工具 GoAccess 安装及使用教程
description: 介绍 goaccess 工具的基本安装方法
---

GoAccess 是一个用来分析 Web 服务器日志的工具，可以对 Nginx 、Apache 的日志进行分析统计。它提供有命令行界面，并且可以生成静态HTML页面形式的分析报告。

### GoAccess 安装方法

 GoAccess 可以使用 yum 工具来安装，也可以手动下载源代码编译安装

#### 在 CentOS 下用 yum 安装

    $ yum install -y goaccess

#### 使用 GoAccess 源码编译安装

编译安装之前需要安装 geoip 依赖开发包

    $ git clone https://github.com/maxmind/geoip-api-c
    $ cd geoip-api-c
    $ ./configure
    $ make
    $ make install

如果不需要 geoip 功能，去掉 `--enable-geoip=legacy` 参数即可

    $ wget http://tar.goaccess.io/goaccess-1.2.tar.gz
    $ tar -xzvf goaccess-1.2.tar.gz
    $ cd goaccess-1.2/
    $ ./configure --enable-utf8 --enable-geoip=legacy
    $ make
    $ make install

### 如何使用 GoAccess 来分析一个 nginx 日志文件

    $ goaccess /var/log/nginx/access.log

启动 GoAccess 然后选择 "Common Log Format (CLF)" 通用格式，运行界面如下

![cli](/assets/img/cli.jpg)

### 使用 GoAccess 生成 HTML 页面

GoAccess 可以将日志分析报告生成静态 HTML 页面以供展示，在使用 GoAccess 生成 HTML 页面之前，需要修改 GoAccess 的配置文件来指定日志格式，注意日志的格式需要根据情况而定

    $ emacs /etc/goaccess.conf
    time-format %H:%M:%S
    date-format %d/%b/%Y
    log-format %h %^[%d:%t %^] "%r" %s %b

使用 GoAccess 生成静态 HTML 页面

    $ goaccess -a -d -f /var/log/nginx/access.log -o report.html

使用 GoAccess 生成的静态 HTML 页面如下

![web](/assets/img/web.jpg)

