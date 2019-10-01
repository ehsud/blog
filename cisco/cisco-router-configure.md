---
layout: post
title: Cisco 路由器常用配置
description: 用于 Cisco 路由器设备的常用功能的配置方法
---

### 常见 Cisco 路由器型号

访问控制列表（ACL）是一种基于包过滤的访问控制技术，它可以根据设定的条件对接口上的数据包进行过滤，允许其通过或丢弃。访问控制列表被广泛地应用于路由器和三层交换机。借助于访问控制列表，可以有效地控制用户对网络的访问，从而最大程度地保障网络安全。

### Cisco 路由器基础配置项

设置 Cisco 路由器主机名

    Router# conf t
    Router(config)# hostname router 

配置开启 `enable` 特权模式密码

    Router(config)# enable secret 123456
    Router(config)# enable password 123456 

配置 console 控制台登录密码

    Router(config)# line console 0
    Router(config-line)# password 123456
    Router(config-line)# logging synchronous

`logging synchronous` 命令作用是减少系统提示信息对 console 控制台命令行的干扰

### 配置 SSH 远程登录

开启 aaa 登录验证，并创建 cisco 用户 密码为 cisco

    Router# conf t
    Router(config)# hostname r1
    Router(config)# ip domain-name todo.com
    Router(config)# crypto key generate rsa modulus 2048

创建一个 admin 登录账号，权限级别 15，密码 123456

    Router(config)# username admin privilege 15 secret 123456

配置 ssh 协议版本为 2，超时 60 秒，登录重试次数 3

    Router(config)# ip ssh version 2
    Router(config)# ip ssh time-out 60
    Router(config)# ip ssh authentication-retries 3

配置 vty 远程登录参数，登录协议为 ssh

    Router(config)# line vty 0 4
    Router(cconfig-line)# login local
    Router(config)# transport input ssh

### 配置 Telnet 远程登录

Router# conf t
Router# line vty 0 4
Router# transport input telnet
Router# password 123456

使用 Telnet 协议需要注意安全问题，tlenet 是一种明文非加密协议，通常建议使用 SSH 远程登录协议

