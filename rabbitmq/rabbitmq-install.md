---
layout: default
title: rabbitmq 安装及基本配置
description: 讲解 rabbitmq 消息队列服务器的基本安装和配置
copyleft: true
---


##### RabbitMQ 安装配置

RabbitMQ 基于 Erlang 运行环境，需要安装和配置 Erlang 的基础环境

**安装 Erlang 环境**

    $ yum install -y erlang

**安装 RabbitMQ**

    wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.6.5/rabbitmq-server-generic-unix-3.6.5.tar.xz
    xz -d rabbitmq-server-generic-unix-3.6.5.tar.xz
    tar -xvf rabbitmq-server-generic-unix-3.6.5.tar
    mv rabbitmq_server-3.6.5 /usr/local

**启动 RabbitMQ**

    cd /usr/local/rabbitmq_server-3.6.5/sbin
    ./rabbitmq-server -detached

**开启 Web 管理**

    ./rabbitmq-plugins enable rabbitmq_management

**创建用户并设置权限和角色**

    rabbitmqctl add_user admin admin
    rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
    rabbitmqctl set_user_tags admin administrator

