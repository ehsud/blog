---
layout: post
title: 如何申请 Let's Encrypt 泛域名 SSL 证书
description: 教你如何申请 Let's Encrypt 的免费 SSL 范域名证书
---

此文将向你介绍如何使用 acme.sh 工具申请 Let's Encrypt 的泛域名证书。如果想了解单域名的证书申请方法，请参考下面这篇文章

- [如何申请 Let's Encrypt 域名证书](/nginx/how-to-use-let's-encryption-certificate.html)

### 什么是泛域名证书？

泛域名英文名称 Wildcard Certificates，指的是你的根域名下的所有子域名，相当于 `*` 星号通配符，例如 `*.example.com`。如果你想给同一根域名下的所有子域名申请证书，就需要申请泛域名证书。接下来我们会用到以下这些工具

- curl、nginx、acme.sh

### 1. 下载和安装 acme.sh 工具

这里 acme.sh 就是我们申请 Let's Encryption 证书的核心工具，acme.sh 是一个自动化的证书管理工具脚本，能够自动和手动更新域名证书，我们可以使用 curl 来下载和安装 acme.sh

```
$ curl  https://get.acme.sh | sh
```

### 2. 使用 acme.sh 工具生成证书

当然生成证书之前，你依然需要确保你对你的域名拥有管理权，不然你无法申请成功。

#### 1. 向 Let's Encryption 发起申请证书请求

使用下面的命令向 Let's Encryption 机构申请注册域名证书，除了用 `-d` 参数指定根域名 `example.com` 之外，还添加了一个 `*.example.com` 泛域名，表示同时为 `example.com` 下的所有子域名申请证书。其中 `example.com` 为演示域名，请自行修改为你的真实域名

```
$ acme.sh --issue --dns -d example.com -d *.example.com --yes-I-know-dns-manual-mode-enough-go-ahead-please
```

- `-d` 指定你需要申请证书的网站域名，这里指定了根域名和一个 `*.example.com` 泛域名
- `--dns` 表示使用 DNS 方式验证域名所有权，也就是你必须对你的域名具有管理权限
- `--yes-I-know-dns-manual-mode-enough-go-ahead-please` 表示以手动操作方式申请域名证书

上面的命令成功执行后，会输出类似下面这样的信息，注意下一步中会用到这些信息

```
[Sat Mar 30 19:21:24 CST 2019] Single domain='example.com'
[Sat Mar 30 19:21:24 CST 2019] Getting domain auth token for each domain
[Sat Mar 30 19:21:25 CST 2019] Getting webroot for domain='example.com'
[Sat Mar 30 19:21:26 CST 2019] Add the following TXT record:
[Sat Mar 30 19:21:26 CST 2019] Domain: '_acme-challenge.example.com'*
[Sat Mar 30 19:21:26 CST 2019] TXT value: 'CZ85YjH3FXZtAYjiVYd1nLu48thbI1EnEKe3pdmVDAw'
[Sat Mar 30 19:21:26 CST 2019] Please be aware that you prepend _acme-challenge. before your domain
[Sat Mar 30 19:21:24 CST 2019] Single domain='*.example.com'
[Sat Mar 30 19:21:24 CST 2019] Getting domain auth token for each domain
[Sat Mar 30 19:21:25 CST 2019] Getting webroot for domain='*.example.com'
[Sat Mar 30 19:21:26 CST 2019] Add the following TXT record:
[Sat Mar 30 19:21:26 CST 2019] Domain: '_acme-challenge.example.com'*
[Sat Mar 30 19:21:26 CST 2019] TXT value: '8FJ8WZtAYjiVYd1JFW923HI1EnEFWUW902309JH3FABn'
[Sat Mar 30 19:21:26 CST 2019] Please be aware that you prepend _acme-challenge. before your domain
[Sat Mar 30 19:21:26 CST 2019] so the resulting subdomain will be: _acme-challenge.example.com
[Sat Mar 30 19:21:26 CST 2019] Please add the TXT records to the domains, and re-run with --renew.
[Sat Mar 30 19:21:26 CST 2019] Please check log file for more details: /root/.acme.sh/acme.sh.log
```

#### 2. 添加 TXT 域名记录

Let's Encryption 需要验证域名 TXT 记录来确定你对域名的所有权，所以需要将上面两个域名`example.com` 和 `*.example.com` 的红色部分的 `Domain` 和 `TXT value` 添加到域名 DNS 记录里。首先你需要登录到你的域名服务商的 DNS 管理平台，然后分别添加两条 TXT 记录

- 第 1 条 TXT 记录，主机名(Host)为： `_acme-challenge`  值(Value)为： `CZ85YjH3FXZtAYjiVYd1nLu48thbI1EnEKe3pdmVDAw` 

- 第 2 条 TXT 记录，主机名(Host)为： `_acme-challenge`  值(Value)为： `8FJ8WZtAYjiVYd1JFW923HI1EnEFWUW902309JH3FABn` 

因为一般 DNS 需要一定的时间才能生效，所以还是按照老传统先吃个瓜等待几分钟，再执行下面的命令开始验证

```
$ acme.sh --renew --dns -d example.com --yes-I-know-dns-manual-mode-enough-go-ahead-please
```

如果以上命令执行完没有错误提示，并且有显示类似 `Success` 的成功字样，就说明证书已申请成功！接下来就可以开始安装证书。

### 3. 开始安装 SSL 证书

这里以 Ningx 为例，需要创建一个证书存放目录，比如 /etc/cert，然后将证书安装到其中即可，其中 `example.key` 和 `example.crt` 证书文件名根据你的域名自行修改

```
$ mkdir /etc/cert
$ acme.sh --install-cert -d example.com --key-file /etc/cert/example.key --fullchain-file /etc/cert/example.crt
```

这样整个证书申请到安装就完成了，接下来就是配置 Nginx 使用 SSL 证书

### 4. 如何给 Nginx 配置使用证书

只需要在 nginx.conf 配置文件中对应的 Server 配置段，添加以下内容即可

```
http {
    server {
        listen       443 ssl;
        server_name  example.com;
        root         /var/www/html;
		
        ssl_certificate     /etc/cert/example.crt;
        ssl_certificate_key /etc/cert/example.key;
        ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers         HIGH:!aNULL:!MD5;
    
        location / {
            index    index.html index.htm;
        }
    }
}
```



