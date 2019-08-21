---
layout: post
title: Cisco VLAN 与单臂路由配置
description: 用于 Cisco 设备的 VLAN 与单臂路由配置
---

### 什么是 VLAN ？

VLAN（Virtual Local Area Network）的全称为 "虚拟局域网"，是一种不受物理位置限制，并且基于接口的逻辑上的局域网络。VLAN 通常称之为 `802.1q` 协议，是一种国际 VLAN 标准协议，市面上大部分品牌设备都支持。每一个 VLAN 属于一个独立的广播域，不同 VLAN 之间默认无法相互通信

### 什么是 access 与 trunk 模式 ？

在 VLAN 网络中，主要有两种接口模式，access 用于终端电脑设备接入使用的接口模式，另外一种就是 trunk 中继接口模式，trunk 接口主要用于不同交换机之间使用，在 trunk 接口上可以设置让某些 VLAN 的数据通过 trunk 接口传输到其他交换机上，当然默认不同交换机上相同的 VLAN 可以通过 trunk 相互通信，而不同交换机上不同的 VLAN 默认不能相互通信

### Cisco 设备的 VLAN 配置方法

创建一个编号为 100 的 VLAN

    Switch> en
    Switch# conf t
    Switch(config)# vlan 100
    Switch(config-vlan)# exit

将 f0/1 接口设置为 access 模式，并加入到 VLAN 100 网络中

    Switch# conf t
    Switch(config)# int f0/1
    Switch(config-if)# switchport mode access 
    Switch(config-if)# switchport access vlan 100
    Switch(config-if)# exit

因为 VLAN 是基于物理接口的，如果接口下面接入的是终端电脑设备，此接口就需要被设置为 access 模式，否则无法使用 VLAN

### 如何让不同 VLAN 之间相互通信 ？

VLAN 是属于一种二层网络协议，需要使用三层路由设备来使不同 VLAN 之间通信，如下图网络拓扑

![vlan-router-on-a-stick.png](/assets/img/vlan-router-on-a-stick.png)

- `10.2.0.2` 与 `10.2.0.3` 属于 VLAN 200 网络
- `10.3.0.2` 与 `10.3.0.3` 属于 VLAN 300 网络
- S1 交换机与 S2 交换机之间使用 trunk 中继端口连接
- S1 交换机 g0/2 接口接一台三层路由器设备作为网关路由

将 S1 交换机 g0/2 端口设置为 trunk 中继接口，并允许所有 VLAN 通过

    Switch# conf t
    Switch(config)# int g0/2
    Switch(config-if)# switchport mode trunk
    Switch(config-if)# switchport trunk allowed vlan all
    Switch(config-if)# exit

先在 Router1 路由器上将 g0/0 接口配置一个子接口与 IP 地址，用于 VLAN 200 的网关

    Router> en
    Router# conf t
    Router(config)# int g0/0.1
    Router(config-subif)# encapsulation dot1Q 200
    Router(config-subif)# ip address 10.2.0.1 255.255.0.0

再在 Router1 路由器上将 g0/0 接口配置一个子接口与 IP 地址，用于 VLAN 300 的网关

    Router> en
    Router# conf t
    Router(config)# int g0/0.2
    Router(config-subif)# encapsulation dot1Q 300
    Router(config-subif)# ip address 10.3.0.1 255.255.0.0

因为路由器 g0/0 接口连接的是 S1 交换机的 g0/2 trunk 接口，所以路由器上 g0/0 的两个子接口需要配置 dotQ 封装协议，并分别设置为 VLAN 200 和 VLAN 300，这样 VLAN 200 的主机能与 g0/0.1 子接口通信，VLAN 300 的主机能与 g0/0.2 子接口通信，将两个子接口 IP 地址作为各自的网关，不同 VLAN 之间就可以通过路由器相互通信