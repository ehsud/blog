---
layout: post
title: 如何创建多域名 Email 邮件服务器
description: 如何在 FreeBSD 下使用 Postfix 和 Opendkim 创建一个多域名 Email 邮件服务器
---

如何使用 postfix 和 Opendkim 搭建一个支持多域名的邮件服务器


## 准备工作

- 服务器环境为 FreBSD 12 、软件包：postfix、opendkim、sendmail
- 配置为 STMP 服务器，只用来发送邮件，不接受任何收件
- 需要一个或多个网站域名，当然没有域名也能发送邮件，但可能会被邮件服务商当成垃圾邮件而拒绝

## 基础软件包安装

    $ pkg install -y postfix sendmail opendkim

## 配置 Postfix 邮件服务器

### 1. 编辑 /etc/postfix/main.cf 文件

```
myhostname = a.com
virtual_alias_maps = hash:/etc/postfix/virtual
virtual_alias_domains=a.com b.com
inet_interfaces = loopback-only
inet_protocols = ipv4
mynetworks = 127.0.0.0/8
milter_protocol = 2
milter_default_action = accept
smtpd_milters = inet:localhost:8891
non_smtpd_milters = inet:localhost:8891
compatibility_level = 3.6
```

设置 `myhostname` 为主域名，`virtual_alias_domains` 为所有域名列表，`virtual_alias_maps` 是所有域名 map 数据库文件

### 2. 编辑 /etc/postfix/virtual 文件

这里添加所有域名邮件地址列表，每行一个地址

```
account@a.com account
support@b.com support
```
修改完 /etc/postfix/virtual 文件，需要执行 postmap 命令生成 virtual.db 数据库文件

```
$ postmap /etc/postfix/virtual
```

重启 Postfix 服务，以使配置生效

    $ service postfix restart

### 3. 测试 Postfix 发送邮件

1. 基本以上配置就能正常工作，我们可以新建一个 mail.txt 文件内容如下

```
Subject: This is an Test email
    
Hi John, This is my first message!
```

- `Subject` 表示邮件标题，这是一个固定格式，然后空一行，之后的就是邮件正文内容

2. 然后我们使用 sendmail 命令将这个 mail.txt 邮件内容发送给别人，例如 john@hotmail.com


    $ sendmail john@hotmail.com < mail.txt

如果对方正常收到邮件，那恭喜顺利完成第一步。当然我们还需要一些额外的配置才能更好的工作。

## 配置 SPF 和 DKIM

什么是 spf 和 DKIM 可以参考这里 [什么是 SPF 和 DKIM ？](/linux/howto), 简单来讲，SPF  和 DKIM 可以防止其他邮件服务商将我们发送的邮件当成垃圾邮件，导致用户无法接收邮件

### 1. 配置 SPF 记录

事实上 SPF 记录配置非常简单，因为它是一种 DNS 记录，所以需要在你的域名服务商系统中去配置即可。例如以新网为例

![spf.jpg](/assets/img/spf.jpg)

也就是添加一条 TXT 记录类型，域名为 example.com ，记录值为 `v=spf1 ip4:66.249.79.75 ~all`，其中 `ip4:` 后面为你的服务器 IP 地址

### 2. 配置 DKIM 记录

DKIM 的也是一种 DNS 记录。不过可能稍微复杂一些，因为 DKIM 需要使用 opendkim 工具来进行配置

1) 首先使用 opendkim 生成域名的公钥和私钥

```
$ opendkim-genkey -s mail -d a.com
```

- `-s` 参数，表示 DKIM 记录的域名前缀，可随意指定，这里以 mail 为例
- `-d` 参数，表示你的邮件服务器域名，可以是根域名，也可以是二级域名



2) 创建密钥存放位置，并将私钥复制到其中

```
$ mkdir -p /etc/opendkim/keys/a
$ copy mail.private /etc/opendkim/keys/a/mail.private
```

> 提示： 在 `/etc/opendkim/keys` 目录下为每个域名创建一个密钥存放目录



3. 然后查看 mail.txt 文件中的内容

```
$ cat mail.txt

mail._domainkey IN      TXT     ( "v=DKIM1; k=rsa; "  "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNAABCiQKBgQCurYK4gbUsqhrBboABC6tRIx9RDfDvhqyQ1IdsUQKfGhVj5HDV6XD4q1cXnZjYXAEBq5j3KDjhTtq/U2gH9iIwr+hL2h+j20e+rPpAz/FU0cHCIFkp1sHH4sfuME98wUmICxg0CHkpatlfL6WFqv6VCwRkqSdjLSMpSaFRZO5gPQIDAQAB" )  ; ----- DKIM key mail for example.com
```
其中我们需要提取出里面的域名部分，在这里需要记录的域名就是

```
mail._domainkey.a.com
```

然后提取出圆括号里面的 DKIM 字符串值，注意不需要双引号，类似下面这样

```
v=DKIM1;k=rsa;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNAABCiQKBgQCurYK4gbUsqhrBboABC6tRIx9RDfDvhqyQ1IdsUQKfGhVj5HDV6XD4q1cXnZjYXAEBq5j3KDjhTtq/U2gH9iIwr+hL2h+j20e+rPpAz/FU0cHCIFkp1sHH4sfuME98wUmICxg0CHkpatlfL6WFqv6VCwRkqSdjLSMpSaFRZO5gPQIDAQAB
```

4. 然后在域名 DNS 管理平台，添加一个 TXT 类型的记录，主机为 `mail._domainkey` ，值为上面提取出来的 DKIM 字符串值

![dkim.jpg](/assets/img/dkim.jpg)

### 3. 配置 OpenDKIM

#### 1. 编辑  opendkim.conf 配置文件

编辑 /usr/local/etc/mail/opendkim.conf 文件

```
Canonicalization	relaxed/simple
ExternalIgnoreList	refile:/etc/opendkim/TrustedHosts
InternalHosts		refile:/etc/opendkim/TrustedHosts
KeyTable            refile:/etc/opendkim/KeyTable
LogWhy		        yes
Mode			    sv
Selector		    mail
SignatureAlgorithm	rsa-sha256
SigningTable		refile:/etc/opendkim/SigningTable
Socket			    inet:8891@localhost
Syslog			    Yes
SyslogSuccess		Yes
UserID		        mailnull:mailnull
```

然后检查以下相关文件，确保这些文件是否存在

- /etc/opendkim/TrustedHosts
- /etc/opendkim/KeyTable

#### 2. 配置 TrustedHosts 文件

编辑 /etc/opendkim/TrustedHosts 文件

```
127.0.0.1
localhost
*.libsd.net
*.lut3d.com
```

#### 3. 配置 KeyTable 文件

编辑 /etc/opendkim/KeyTable 文件

```
mail._domainkey.libsd.net libsd.net:mail:/etc/opendkim/keys/a/mail.private
mail._domainkey.lut3d.com lut3d.com:mail:/etc/opendkim/keys/b/mail.private
```

其中指定了每个域名和对应的 DKIM 密钥文件路径

最后重启 OpenDKIM 服务即可

```
$ service milter-opendkim restart
```

