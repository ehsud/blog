---
layout: post
title: 华为 AC 控制器配置
description: 用于 Cisco 路由器设备的常用功能的配置方法
---

### WLAN 网络规划

- R1 路由器作为 STA 的网关以及 DHCP 服务器，业务 VLAN 为 100
    - R1 路由器 GE0/0/1 口 IP 地址 192.168.1.1/24
    - 分配给 STA 的网络地址为 192.168.1.0/24 网段，网关为 192.168.1.1

- AC 控制器作为 AP 的网关以及 DHCP 服务器，管理 VLAN 为 10
    - AC 路由器 vlan 10 接口 IP 地址 10.10.10.1/24
    - 分配给 AP 的网络地址为 10.10.10.0/24 网段，网关为 10.10.10.1

### R1 路由器配置


### AC 控制器配置

1. 创建 AP 管理 VLAN 和 STA 业务 VLA

```
[AC] vlan batch 10 100
```

2. 配置 AP 管理 VLAN IP地址

```
[AC] interface Vlanif 10
[AC-Vlanif10] ip address 10.10.10.1 255.255.255.0
[AC-Vlanif10] quit
```

4. 为 AC 配置源接口

```
[AC] capwap source interface vlanif 10
```

3. 为 AP 配置 DHCP 服务

```
[AC] interface Vlanif 10
[AC-Vlanif10] dhcp select interface
[AC-Vlanif10] network 10.10.10.0 mask 255.255.255.0
[AC-Vlanif10] gateway-list 10.10.10.1
[AC-Vlanif10] dns-list 8.8.8.8
[AC-Vlanif10] lease day 1
[AC-Vlanif10] quit
```

5. 创建 domain 域管理模板，在域管理模板下配置国家代码

```
[AC] wlan
[AC-wlan-view] regulatory-domain-profile name domain
[AC-wlan-regulate-domain-domain] country-code cn
[AC-wlan-regulate-domain-domain] quit
```

4. 创建 AP 组，并引用上面创建的域管理模板

```
[AC] wlan
[AC-wlan-view] ap-group name ap
[AC-wlan-ap-group-ap] regulatory-domain-profile domain
[AC-wlan-ap-group-ap] quit
[AC-wlan-view] quit
```

7. 设置 AP 认证模式为 MAC 地址认证

```
[AC] wlan
[AC-wlan-view] ap auth-mode mac-auth
```

7. 添加 AP 自动上线，如果有多个 AP，`ap-id` 和 `ap-name` 不重复即可

```
[AC-wlan-view] ap-id 1 ap-mac 60de-4476-e360 ap-sn 210235448310A02C067C
[AC-wlan-ap-0] ap-name ap1
[AC-wlan-ap-0] ap-group ap
[AC-wlan-ap-0] quit
```

6. 使用 `display ap all` 查看所有上线的 AP，其中 `State` 状态为 `nor` 表示上线成功

```
[AC] dis ap all 
 
ID   MAC            Name Group IP          Type            State STA Uptime
--------------------------------------------------------------------------------
1    00e0-fcb2-4700 ap1  ap    10.10.10.43 AP4050DN-E      nor   0   41M:46S
2    00e0-fc5e-1ee0 ap2  ap    10.10.10.66 AP4050DN-E      nor   0   40M:46S
3    00e0-fcf0-6ff0 ap3  ap    10.10.10.21 AP4050DN-E      nor   0   38M:20S
--------------------------------------------------------------------------------
```

7. 创建 security 安全模板，名称为 security

```
[AC] wlan
[AC-wlan-view] security-profile name security
[AC-wlan-sec-prof-security] security wpa2 psk pass-phrase 12345678 aes
[AC-wlan-sec-prof-security] quit

```

配置为 WPA2 + PSK + AES 的安全策略，密码为 12345678

8. 创建 ssid 模板，名称为 ssid

```
[AC-wlan-view] ssid-profile name ssid 
[AC-wlan-ssid-prof-ssid] ssid wifi
[AC-wlan-ssid-prof-ssid] quit

```

9. 配置 AP 有线接口模板

```
[AC-wlan-view] wired-port-profile name lan
[AC-wlan-wired-port-lan] mode endpoint
[AC-wlan-wired-port-lan] vlan pvid 100
[AC-wlan-wired-port-lan] vlan untagged 100
[AC-wlan-wired-port-lan] quit

[AC-wlan-view] wired-port-profile name trunk
[AC-wlan-wired-port-trunk] mode root
[AC-wlan-wired-port-trunk] vlan tagged 10 100
[AC-wlan-wired-port-trunk] quit  
```

11. 将 wired 有线模板绑定到 AP

```
[AC-wlan-view] ap-id 1
[AC-wlan-ap-group-ap] wired-port-profile trunk gigabitethernet 0
[AC-wlan-ap-group-ap] wired-port-profile lan gigabitethernet 1
[AC-wlan-ap-group-ap] quit
``` 

12. 将 wired 有线模板绑定到 AP 组 (可选)

```
[AC-wlan-view] ap-group name ap
[AC-wlan-ap-group-ap] wired-port-profile trunk gigabitethernet 0
[AC-wlan-ap-group-ap] wired-port-profile lan gigabitethernet 1
[AC-wlan-ap-group-ap] quit
```


13. 创建 vap 模板，并关联安全模板与 ssid 模板

```
[AC-wlan-view] vap-profile name vap 
[AC-wlan-vap-prof-vap] forward-mode direct-forward   
[AC-wlan-vap-prof-vap] service-vlan vlan-id 100
[AC-wlan-vap-prof-vap] security-profile security   
[AC-wlan-vap-prof-vap] ssid-profile ssid
[AC-wlan-vap-prof-vap] quit
```

- `forward-mode` AC 数据转发模式

- `service-vlan` 配置 STA 的业务 VLAN 编号

- `security-profile` 绑定 security 安全模板

- `ssid-profile` 绑定 ssid 模板

14. 在 AP 组引用 VAP 模板，AP 上射频 0 和射频 1 使用 VAP 模板的配置

```
[AC-wlan-view] ap-group name ap
[AC-wlan-ap-group-ap] vap-profile vap wlan 1 radio 0
[AC-wlan-ap-group-ap] vap-profile vap wlan 1 radio 1
[AC-wlan-ap-group-ap] quit
```

15. 手动配置某个 AP 的 2.4G 和 5G 射频的信道和功率

关闭射频的信道和功率自动调优功能，否则会导致手动配置不生效

```
[AC-wlan-view] rrm-profile name default
[AC-wlan-rrm-prof-default] calibrate auto-channel-select disable
[AC-wlan-rrm-prof-default] calibrate auto-txpower-select disable
[AC-wlan-rrm-prof-default] quit
```

配置 AP 射频 0 (2.4G) 的信道和功率

```
[AC-wlan-view] ap-id 1
[AC-wlan-ap-1] radio 0
[AC-wlan-radio-1/0] channel 20mhz 6
[AC-wlan-radio-1/0] eirp 127
[AC-wlan-radio-1/0] quit
```

配置 AP 射频 1 (5G) 的信道和功率

```
[AC-wlan-ap-1] radio 1
[AC-wlan-radio-1/1] channel 20mhz 149
[AC-wlan-radio-1/1] eirp 127
[AC-wlan-radio-1/1] quit
[AC-wlan-ap-1] quit
```

16. 查看所有 AP 的 2.4G 和 5G 射频信号状态

```
[AC] wlan     
[AC-wlan-view]dis vap ssid wifi

----------------------------------------------------------------------
AP ID AP name RfID WID  BSSID          Status  Auth type  STA   SSID
----------------------------------------------------------------------
1     ap1     0    1    00E0-FCB2-4700 ON      WPA2-PSK   0     wifi
1     ap1     1    1    00E0-FCB2-4710 ON      WPA2-PSK   0     wifi
2     ap2     0    1    00E0-FC5E-1EE0 ON      WPA2-PSK   0     wifi
2     ap2     1    1    00E0-FC5E-1EF0 ON      WPA2-PSK   0     wifi
3     ap3     0    1    00E0-FCF0-6FF0 ON      WPA2-PSK   0     wifi
3     ap3     1    1    00E0-FCF0-7000 ON      WPA2-PSK   0     wifi
----------------------------------------------------------------------
```
