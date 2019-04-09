---
layout: default
title: php7 compile install
---

##### PHP 7 编译安装

* php 7.2.2
* 开启 php-fpm
* 开启 pdo 扩展
* 开启 pgsql 扩展

##### 安装 php 所需依赖包

- gcc、gcc-c++、make、autoconf、automake、libtool  
- libxml2-devel、re2c、flex、bison、curl、openssl

##### 开始编译 PHP 7

    $ wget http://cn2.php.net/distributions/php-7.2.2.tar.gz
    $ tar -zxvf php-7.2.2.tar.gz
    $ cd php-7.2.2
    $ ./configure --prefix=/usr/local/php
                --enable-fpm
                --with-openssl
                --enable-mbstring
                --with-curl
                --enable-zip

    $ make
    $ make install

- 如果需要安装 pgsql 数据库扩展，添加以下编译参数，设置为 postgresql 的安装目录即可

```
--with-pdo-pgsql=/usr/local/postgresql
--with-pgsql=/usr/local/postgresql
```

##### systemd 服务脚本 /etc/systemd/system/php.service

    [Unit]
    Description=The PHP FastCGI Process Manager
    After=network.target

    [Service]
    Type=forking
    PIDFile=/tmp/php-fpm.pid
    ExecStart=/usr/local/php/sbin/php-fpm -D -c /etc/php.ini -y /etc/php-fpm.conf
    ExecReload=/bin/kill -USR2 $MAINPID

    [Install]
    WantedBy=multi-user.target

- 开启 php 服务

```
$ systemctl enable php.service
```

- 启动 php 服务

```
$ systemctl start php.service
```

