---
layout: post
title: 如何创建一个 Email 邮件服务器
description: 如何在 Linux 下使用 Postfix 和 Opendkim 创建一个 Email 邮件服务器
---

最近在做网站用户注册模块，很多网站会要求手机绑定和短信验证码。但因为考虑到成本和个人隐私方面的问题，我们采用了最简单的邮箱验证码注册方式，此文档将讲解如何使用 postfix 创建一个基础的 Email 邮件服务器


### 前期准备工作

- 服务器环境为 CentOS 7 、用到的基础软件：postfix、opendkim、sendmail   
- 这里邮件服务器，只用来用户注册发送验证码和通知使用，为了安全，而不会处理任何的收件功能。
- 你需要一个网站域名，当然没有域名也能发送邮件，但可能会被邮件服务商当成垃圾邮件而拒绝

### 安装基础软件包

    $ yum install -y postfix sendmail opendkim

### 配置 Postfix 邮件服务器

编辑 /etc/postfix/main.cf 配置文件

    myhostname = example.com
    mydomain = example.com
    inet_interfaces = loopback-only
    inet_protocols = ipv4
    mynetworks = 127.0.0.0/8

重启 Postfix 服务，以使配置生效

    $ systemctl restart postfix

基本以上配置就能正常工作，我们可以新建一个 mail.txt 文件内容如下

    Subject: This is an Test email
    
    Hi John, This is my first message!

- `Subject` 表示邮件标题，这是一个固定格式，然后空一行，之后的就是邮件正文内容

然后我们使用 sendmail 命令将这个 mail.txt 邮件内容发送给别人，例如 john@hotmail.com


    $ sendmail john@hotmail.com < mail.txt

如果对方正常收到邮件，那恭喜顺利完成第一步。当然我们还需要一些额外的配置才能更好的工作。

### 什么是 SPF 和 DKIM

以上对 postfix 的配置，能让邮件服务器正常工作起来，但你会发现一些问题，那就是有时候当我们给别人发送邮件的时候，对方可能看不到我们发送的邮件，因为目前大部分邮箱服务商都有垃圾邮件过滤系统，它们会根据你的域名 SPF 和 DKIM 记录、当然还包括邮件标题、内容等检测垃圾邮件并进行过滤

所以要配置一个邮件服务器，SPF 和 DKIM 记录是标配。那什么是 SPF 和 DKIM ？嗯，不废话简单几句概括：

#### SPF (Sender Policy Framework)

SPF 是为了防范垃圾邮件而提出来的一种 DNS 记录类型，它是一种 TXT 类型的记录，它用于登记某个域名拥有的，用来对外发邮件的所有服务器的 IP 地址，大部分邮件服务商会检测这个 SPF 记录来过滤垃圾邮件

#### DKIM (DomainKeys Identified Mail)

DKIM 电子邮件验证标准、又称域名密钥识别邮件标准，用来防止电子邮件欺骗，它使用非对称私钥对邮件进行签名，也就是发送方会在电子邮件的标头插入 DKIM-Signature 字段以及电子签名，然后接收方通过查询 DNS 的 DKIM 记录得到公钥然后对邮件进行验证，与 SPF 类似都是为了防止垃圾邮件泛滥而设计的

如果我们不配置 SPF 和 DKIM 记录，那我们所发送的邮件大部分都会被当成垃圾邮件处理

### 如何配置 SPF 记录

事实上 SPF 记录配置非常简单，因为它是一种 DNS 记录，所以需要在你的域名服务商系统中去配置即可。例如以新网为例

![spf.jpg](/assets/img/spf.jpg)

也就是添加一条 TXT 记录类型，域名为 example.com ，记录值为 `v=spf1 ip4:66.249.79.75 ~all`，其中 `ip4:` 后面为你的服务器 IP 地址

### 如何配置 DKIM 记录

DKIM 的也是一种 DNS 记录。不过可能稍微复杂一点，因为 DKIM 需要使用 opendkim 工具来进行配置

1) 首先使用 opendkim 生成公钥和私钥文件

    $ opendkim-genkey -s mail -d example.com

- `-s` 参数，表示 DKIM 记录的域名前缀，可随意指定，这里以 mail 为例
- `-d` 参数，表示你的邮件服务器域名，可以是根域名，也可以是二级域名

2) 创建密钥存放位置，并将私钥复制到其中

    $ mkdir -p /etc/opendkim/keys
    $ copy mail.private /etc/opendkim/keys/dkim.key

3) 然后查看 opendkim 生成的 DKMI 记录 mail.txt 文件内容

    $ cat mail.txt
    
    mail._domainkey IN      TXT     ( "v=DKIM1; k=rsa; "
          "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNAABCiQKBgQCurYK4gbUsqhrBboABC6tRIx9RDfDvhqyQ1IdsUQKfGhVj5HDV6XD4q1cXnZjYXAEBq5j3KDjhTtq/U2gH9iIwr+hL2h+j20e+rPpAz/FU0cHCIFkp1sHH4sfuME98wUmICxg0CHkpatlfL6WFqv6VCwRkqSdjLSMpSaFRZO5gPQIDAQAB" )  ; ----- DKIM key mail for example.com

4) 其中我们需要提取出里面的域名部分，最终需要添加记录的域名就是

    mail._domainkey.example.com

5) 然后需要提取出圆括号里面的 DKIM 记录值部分，注意不需要双引号

    v=DKIM1;k=rsa;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNAABCiQKBgQCurYK4gbUsqhrBboABC6tRIx9RDfDvhqyQ1IdsUQKfGhVj5HDV6XD4q1cXnZjYXAEBq5j3KDjhTtq/U2gH9iIwr+hL2h+j20e+rPpAz/FU0cHCIFkp1sHH4sfuME98wUmICxg0CHkpatlfL6WFqv6VCwRkqSdjLSMpSaFRZO5gPQIDAQAB

6) 然后在域名 DNS 管理平台，添加一个 TXT 类型记录即可，值为上面提取出来的 DKIM 记录值

![dkim.jpg](/assets/img/dkim.jpg)


文章未完待续。。。。

