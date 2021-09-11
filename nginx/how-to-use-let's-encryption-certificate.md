---
layout: post
title: 如何使用 Let's Encrypt 域名 SSL 证书
description: 教你如何使用 Let's Encrypt 的免费 SSL 证书给网站启用 https
---

Let's Encrypt 是一个于 2015 年成立的数字证书认证机构，他们主要为网站提供免费的SSL/TLS证书。旨在简化创建和安装证书的流程，使更多的人使用安全的互联网服务。 

### 前期的准备工作

如果你有一个网站域名，希望使用 https 的安全连接方式进行访问，那么你就需要一个 SSL 证书来实现。本文我们以 Nginx 服务器为例，讲解如何使用 Let's Encryption 的免费 SSL 证书为我们的网站启用 https 服务。这里我们会用到下面这些工具：

- curl、nginx、acme.sh

### 1. 下载和安装 acme.sh 工具

这里 acme.sh 就是我们申请 Let's Encryption 证书的核心工具，acme.sh 是一个自动化的证书管理工具脚本，能够自动和手动更新域名证书，我们可以使用 curl 来下载和安装 acme.sh

```
$ curl  https://get.acme.sh | sh
```

### 2. 使用 acme.sh 工具生成证书

> 这里给单个域名申请域名证书，当然生成证书之前，你需要确保你对你的域名拥有管理权，不然你无法申请成功。

#### 1. 向 Let's Encryption 发起申请证书请求

使用下面的命令向 Let's Encryption 机构申请注册域名证书，其中 `example.com` 为演示域名，请自行修改为你的真实域名

```
$ acme.sh --issue --dns -d example.com --yes-I-know-dns-manual-mode-enough-go-ahead-please
```

- `-d` 指定你需要申请证书的网站域名，当然可以使用多个 `-d` 参数指定多个子域名
- `--dns` 表示使用 DNS 方式验证域名所有权，也就是你必须对你的域名具有管理权限
- `--yes-I-know-dns-manual-mode-enough-go-ahead-please` 表示以手动操作方式申请域名证书

上面的命令成功执行后，会输出类似下面这样的信息

```
[Sat Mar 30 19:21:24 CST 2019] Single domain='example.com'
[Sat Mar 30 19:21:24 CST 2019] Getting domain auth token for each domain
[Sat Mar 30 19:21:25 CST 2019] Getting webroot for domain='example.com'
[Sat Mar 30 19:21:26 CST 2019] Add the following TXT record:
[Sat Mar 30 19:21:26 CST 2019] Domain: '_acme-challenge.example.com'*
[Sat Mar 30 19:21:26 CST 2019] TXT value: 'CZ85YjH3FXZtAYjiVYd1nLu48thbI1EnEKe3pdmVDAw'
[Sat Mar 30 19:21:26 CST 2019] Please be aware that you prepend _acme-challenge. before your domain
[Sat Mar 30 19:21:26 CST 2019] so the resulting subdomain will be: _acme-challenge.example.com
[Sat Mar 30 19:21:26 CST 2019] Please add the TXT records to the domains, and re-run with --renew.
[Sat Mar 30 19:21:26 CST 2019] Please check log file for more details: /root/.acme.sh/acme.sh.log
```

#### 2. 添加 TXT 域名记录

Let's Encryption 需要验证域名 TXT 记录来确定你对域名的所有权，所以需要将上面红色部分的 `Domain` 和 `TXT value` 添加到域名 DNS 记录里。首先你需要登录到你的域名服务商的 DNS 管理平台，然后增加一个 TXT 文本记录，主机名(Host)为： `_acme-challenge`  值(Value)为： `CZ85YjH3FXZtAYjiVYd1nLu48thbI1EnEKe3pdmVDAw` 即可，因为一般 DNS 需要一定的时间才能生效，所以先吃个瓜等待几分钟，再执行下面的命令开始验证

```
$ acme.sh --renew --dns -d example.com --yes-I-know-dns-manual-mode-enough-go-ahead-please
```

如果以上命令执行完没有错误提示，并且有显示类似 `Success` 的成功字样，就说明证书已申请成功！接下来就可以开始安装证书。

### 3. 开始安装 SSL 证书

这里以 Ningx 为例，需要创建一个证书存放目录，比如 /etc/cert，然后将证书安装到其中即可，其中 `example.key` 和 `example.crt` 证书文件根据你的域名自行修改

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

### 5. 如何给泛域名申请  SSL 域名证书

泛域名指的是你的跟域名下的所有子域名，相当于 `*` 星号通配符，例如 `*.example.com`。如果你想给同一根域名下的所有子域名申请证书，就需要申请泛域名证书。只需要在 第 1 步申请命令中添加 `-d` 参数新增一个 `*.example.com` 域名即可

```
$ acme.sh --issue --dns -d example.com -d *.example.com --yes-I-know-dns-manual-mode-enough-go-ahead-please
```

然后完成后续的添加 TXT 记录，重新 renew 验证后，这样多个子域名就可共用同一个证书，无需为每个子域名申请证书。

