---
layout: post
title: 如何使用 Let's Encrypt 域名 SSL 证书
description: 教你如何使用 Let's Encrypt 的免费 SSL 证书给网站启用 https
copyleft: true
---

Let's Encrypt 是一个于 2015 年成立的数字证书认证机构，他们主要为网站提供免费的SSL/TLS证书。旨在简化创建和安装证书的流程，使更多的人使用安全的互联网服务。 

### 前期的准备工作

如果你有一个网站域名，希望使用 https 的安全连接方式进行访问，那么你就需要一个 SSL 证书来实现。本文我们以 Nginx 服务器为例，讲解如何使用 Let's Encryption 的免费 SSL 证书为我们的网站启用 https 服务。

当然我们会用到下面这些工具：

- curl
- nginx
- acme.sh

### 1. 下载和安装 acme.sh 工具

我们需要先下载和安装 acme.sh 证书工具，acme.sh 是一个自动化的证书管理工具脚本

```
$ curl  https://get.acme.sh | sh
```

### 2. 开始使用 acme.sh 生成证书

- 给单个域名申请域名 SSL 证书

首先向 Let's Encryption 机构申请注册证书。当然生成证书之前，你需要确保你对你的域名拥有管理权，不然你无法申请成功。

```
$ acme.sh --issue --dns -d example.com --yes-I-know-dns-manual-mode-enough-go-ahead-please
```

> `-d` 指定你需要申请证书的网站域名，当然可以使用多个 `-d` 参数指定多个子域名
> `--dns` 表示使用 DNS 方式验证域名所有权，也就是你必须对你的域名具有管理权限
> `--yes-I-know-dns-manual-mode-enough-go-ahead-please` 表示以手动操作方式管理域名证书的申请

上面的命令成功执行后，会输出类似下面的信息

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

红色部分的 `Domain` 和 `TXT value` 的域名和验证字符串需要记住，他的意思就是现在需要验证你对域名的所有权。首先你需要登录到你的域名服务商的 DNS 管理平台，然后增加一个 `_acme-challenge.example.com` 子域名，并且设置这个子域名的 TXT 记录为 `CZ85YjH3FXZtAYjiVYd1nLu48thbI1EnEKe3pdmVDAw` 即可，然后等待几分钟，因为一般 DNS 需要一定的时间才能生效。

- 然后开始重新申请证书

```
$ acme.sh --renew --dns -d example.com --yes-I-know-dns-manual-mode-enough-go-ahead-please
```

如果以上命令执行完没有错误提示，就说明证书已申请成功！下面就开始为 Nginx 安装证书。

### 3. 开始安装 SSL 证书

需要创建一个证书存放目录，比如 /etc/cert，然后将证书安装到其中即可

```
$ mkdir /etc/cert
$ acme.sh --install-cert -d example.com --key-file /etc/cert/example.key --fullchain-file /etc/cert/example.crt
```

这样整个证书申请到安装就完成了，接下来就是配置 Nginx 使用 SSL 证书

### 4. 如何给 Nginx 配置使用证书

只需要在 nginx.conf 配置文件中的 http 段，添加以下内容即可

```
http {

    ssl_certificate     /etc/cert/example.crt;
    ssl_certificate_key /etc/cert/example.key;
    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    server {
        listen       443 ssl;
        server_name  example.com;
        root         /var/www/html;

        location / {
            index    index.html index.htm;
        }
    }
}
```

### 5. 如何给泛域名申请  SSL 域名证书

泛域名指的是，如果你想给同一根域名下的多个子域名申请证书，可这样做

```
$ acme.sh --issue --dns -d example.com -d *.example.com --yes-I-know-dns-manual-mode-enough-go-ahead-please
```

也就是只需要增加一个 `-d` 参数指定为 `*.example.com` 即可，这样多个子域名就可公用一个证书

