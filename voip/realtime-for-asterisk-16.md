---
layout: post
title: Asterisk 16 Realtime 配置手记
description: 详解 Asterisk 16 的 Realtime 配置方法
---

Asterisk 16 的 Realtime 配置方法，配配置 Realtime 之前，确保已经正确安装了 Asterisk，否则请先安装好基础的 Asterisk 再继续

### 准备环境

* CentOS 7 x64
* PostgreSQL 12
* Asterisk 16 certified

1. 首先安装必须的数据库工具，以及相关依赖

```
$ yum install -y python-pip python-psycopg2
$ pip install alembic
```

2. 在 asterisk 源码目录下，重命名 alembic 的配置文件

```
$ cd contrib/ast-db-manage
$ mv config.ini.sample config.ini
```

3. 修改 alembic 的 config.ini 配置文件中的数据库配置项

```
sqlalchemy.url = postgresql://postgres:123456@127.0.0.1/asterisk
```

4. 然后使用 alembic 将相关 Realtime 数据库表导入 PostgreSQL 中

```
$ alembic -c config.ini upgrade head
```

以上操作就是将基础的 Realtime 数据库表创建完成，以便在后面的配置中让 Asterisk 使用数据库来保存各种模块配置


### 配置 Asterisk 使用 Realtime 数据库


1. 修改 res_pgsql.conf 配置文件

```
[general]
dbhost=127.0.0.1
dbport=5432
dbname=asterisk
dbuser=postgres
dbpass=123456
requirements=warn
```

此处主要配置 Realtime 的数据连接信息，比如数据库用户、密码、数据库名称

2. 修改 extconfig.conf 配置文件

```
[settings]
ps_endpoints => pgsql,asterisk
ps_auths => pgsql,asterisk
ps_aors => pgsql,asterisk
ps_domain_aliases => pgsql,asterisk
ps_endpoint_id_ips => pgsql,asterisk
ps_outbound_publishes => pgsql,asterisk
ps_inbound_publications = pgsql,asterisk
```

此处 extconfig.conf 主要用于配置 realtime 的数据库表映射

3. 修改 sorcery.conf 配置文件

```
[res_pjsip]
endpoint=realtime,ps_endpoints
auth=realtime,ps_auths
aor=realtime,ps_aors
domain_alias=realtime,ps_domain_aliases

[res_pjsip_endpoint_identifier_ip]
identify=realtime,ps_endpoint_id_ips

[res_pjsip_outbound_publish]
outbound-publish=realtime,ps_outbound_publishes

[res_pjsip_pubsub]
inbound-publication=realtime,ps_inbound_publications

[res_pjsip_publish_asterisk]
asterisk-publication=realtime,ps_asterisk_publications
```

### PJSIP 全局配置

1. 在 pjsip.conf 文件中，添加一个 transport 配置节点，因为 transport 不允许在 realtime 数据库中配置

```
[transport-udp]
type = transport
protocol = udp
bind = 0.0.0.0
```

2. 在 Realtime 数据库中添加两个分机号码，以作为测试

```
pgsql> insert into ps_aors (id, max_contacts) values (102, 1);
pgsql> insert into ps_auths (id, auth_type, password, username) values (101, 'userpass', 101, 101);
pgsql> insert into ps_auths (id, auth_type, password, username) values (102, 'userpass', 102, 102);
pgsql> insert into ps_endpoints (id, transport, aors, auth, context, disallow, allow, direct_media) values (101, 'transport-udp', '101', '101', 'testing', 'all', 'ulaw,alaw', 'no');
pgsql> insert into ps_endpoints (id, transport, aors, auth, context, disallow, allow, direct_media) values (102, 'transport-udp', '102', '102', 'testing', 'all', 'ulaw,alaw', 'no');
```
