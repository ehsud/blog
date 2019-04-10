---
layout: post
title: postgresql 10 编译安装及配置
description: 讲解如何编译安装 postgresql 10 数据库
---

使用 CentOS 7.4 环境，PostgreSQL 10 版本

#### 依赖开发包安装

    $ yum install -y gcc gcc-c++ make readline-devel zlib-devel openssl-devel perl-devel libxml2-devel systemd-devel

#### 编译 PostgreSQL 源码

    $ tar -zxvf postgresql-10.2.tar.gz
    $ cd postgresql-10.2
    $ ./configure --prefix=/usr/local/postgresql --with-systemd
    $ make
    $ make install

#### 创建运行用户

    $ useradd -m -d /var/pgsql -c "postgresql databases user" postgres

#### 创建数据库目录

    $ mkdir -p /var/pgsql/data
    $ chown -R postgres:postgres /var/pgsql/data

#### 初始化数据库

    $ su - postgres
    $ /usr/local/postgresql/bin/initdb --pgdata=/var/pgsql/data --encoding=UTF8

#### 相关配置文件

pg_hba.conf

    local   all             all                                     trust
    host    all             all             127.0.0.1/32            md5

postgresql.conf

    listen_addresses = '127.0.0.1'
    port = 5432
    max_connections = 128
    shared_buffers = 256MB
    work_mem = 16MB
    maintenance_work_mem = 64MB
    effective_cache_size = 256MB

#### systemd 服务脚本

创建 /etc/systemd/system/postgresql.service 配置文件

```
[Unit]
Description=PostgreSQL database server
After=network.target

[Service]
Type=forking
User=postgres
Group=postgres
LimitNPROC=65535
LimitNOFILE=102400
OOMScoreAdjust=-1000
TimeoutSec=300

ExecStart=/usr/local/postgresql/bin/pg_ctl -D /var/pgsql/data -s -w -t 300 start
ExecStop=/usr/local/postgresql/bin/pg_ctl -D /var/pgsql/data -s -m fast stop
ExecReload=/usr/local/postgresql/bin/pg_ctl -D /var/pgsql/data -s reload

[Install]
WantedBy=multi-user.target
```

开启 postgresql 服务

    $ systemctl enable postgresql.service

启动 postgresql 服务

    $ systemctl start postgresql.service

手动启动 PostgreSQL 服务

    $ /usr/local/postgresql/bin/pg_ctl -D /var/pgsql/data -l /tmp/postgresql.log start

#### 内核参数优化

编辑 /etc/sysctl.conf 内核配置文件

```
fs.nr_open = 2048000
fs.file-max = 1024000
fs.aio-max-nr = 1048576
net.ipv4.tcp_fin_timeout = 5
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
```

编辑 /etc/security/limits.conf 内核配置文件

```
* soft    nofile  1024000
* hard    nofile  1024000
* soft    nproc   unlimited
* hard    nproc   unlimited
* soft    core    unlimited
* hard    core    unlimited
* soft    memlock unlimited
* hard    memlock unlimited
```

