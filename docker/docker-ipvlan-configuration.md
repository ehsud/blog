---
layout: post
title: Docker ipvlan 网络配置
description: 使用 Docker 的 IPVLAN 网络驱动部署容器
---

### docker 使用 ipvlan 网络

- Archlinux 
- Docker 1.13

系统环境为 archlinux，ipvlan 属于 Linux 的一个内核模块, 所以要求 Linux 内核版本要大于 4.2 因为 ipvlan 的特性，容器默认无法与容器所在宿主机的 enp0s3 网卡通信，但可以跨主机与其他主机或者其他主机上的容器通信，在当前的 docker 网络驱动 `bridge`、`host`、`overlay`、`macvlan`、`ipvlan` 当中，`macvlan` 和 `ipvlan` 的网络性能效率是最高的。

### 配置 docker 网络使用 ipvlan

docker 的 ipvlan 网络驱动属于实验性功能，必须要开启 docker 的 Experimental 功能，也就是需要修改 docker 的配置文件 /etc/docker/daemon.json


    {
        "experimental": true
    }


宿主机 IP 地址


    $ ip addr show enp0s3
    enp0s3 inet 192.168.1.100/24 scope global enp0s3


创建 docker 网络

    $ docker network  create -d ipvlan --subnet=192.168.1.0/24 --gateway=192.168.1.1 -o parent=enp0s3 ipvlan

- `-d` 指定 docker 的网络驱动为 ipvlan
- `--subnet` 指定创建的容器网络子网范围
- `--gateway` 指定创建的容器网络的默认网关
- `-o parent` 表示使用宿主机的 enp0s3 物理网卡作为桥接

查看 docker 的当前所有网络信息


    $ docker network ls


启动测试容器，使用手动方式为容器分配 IP 地址


    $ docker  run --net=ipvlan --name=c1 --ip 192.168.1.2 -itd alpine /bin/sh
    $ docker  run --net=ipvlan --name=c2 --ip 192.168.1.3 -it --rm alpine /bin/sh


可以在任意容器内 ping 另外一个容器的 ip 进行测试


    $ ping 192.168.1.2


### 需要注意的问题

就像一开始所讲的，当容器工作在 ipvlan 网络模式下，容器默认情况下是无法与所在宿主机相互通信的

